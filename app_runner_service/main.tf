/*

# Purpose

Create an App Runner service based on a Docker image hosted on an ECR repository.

# Notes

1. Use `terraform apply -target=aws_ecr_repository.ecr_repository` to create an ECR repository and
   upload your Docker image to that repository before running a full `terraform apply`. Otherwise,
   the App Runner service cannot be created because it cannot load the Docker image.
2. It's recommended to use a Docker image tag such as "production" so that you can deploy simply by
   updating that tag on ECR. You can also deploy by specifying a different tag, but this takes about
   6 minutes to complete and is considered a service update rather than a deployment by App Runner.
3. Associating a domain name is optional. If you do associate one, the process is fully automated.

# Usage

resource "aws_ecr_repository" "ecr_repository" {
  name = "my-service"
}

module "app_runner_service" {
  source           = "github.com/radix-ai/terraform-modules//app_runner_service"
  service_name     = "my-service"
  image_repository = aws_ecr_repository.ecr_repository.repository_url
  image_tag        = "production"
}

module "app_runner_service" {
  source                       = "github.com/radix-ai/terraform-modules//app_runner_service"
  hosted_zone_id               = aws_route53_zone.domain.zone_id
  domain_name                  = "api.example.com"
  service_name                 = "my-service"
  image_repository             = aws_ecr_repository.ecr_repository.repository_url
  image_tag                    = "production"
  start_command                = "serve"
  health_check_endpoint        = "/healthcheck"
  environment_variables        = {MY_VAR = "MY_VAL"}
  instance_cpu                 = "1 vCPU"
  instance_memory              = "2 GB"
  max_concurrency_per_instance = 50
  min_instances                = 1
  max_instances                = 10
  port                         = 8000
}

resource "aws_iam_role_policy_attachment" "s3_read_access" {
  role       = module.app_runner_service.instance_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# References

[1] https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apprunner_service
[2] https://docs.aws.amazon.com/apprunner/latest/dg/security_iam_service-with-iam.html#security_iam_service-with-iam-roles

*/

# Create an auto-scaling configuration for the App Runner service.
resource "aws_apprunner_auto_scaling_configuration_version" "auto_scaling_config" {
  auto_scaling_configuration_name = "auto_scaling_config"
  max_concurrency                 = var.max_concurrency_per_instance
  min_size                        = var.min_instances
  max_size                        = var.max_instances
}

# Create a role that App Runner may assume [2] to deploy the service.
resource "aws_iam_role" "deploy_role" {
  name = "${var.service_name}-deploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

# Allow App Runner to access ECR with the deploy role [2].
resource "aws_iam_role_policy_attachment" "deploy_role_policy_attachment" {
  role       = aws_iam_role.deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# Create a role that App Runner may assume [2] to run the service.
# Note: this module's consumers may add an `aws_iam_role_policy_attachment` or an `aws_iam_role_policy` to modify the role's permissions.
resource "aws_iam_role" "instance_role" {
  name = "${var.service_name}-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
      }
    ]
  })
}
locals {
  instance_role_name = aws_iam_role.instance_role.name
}

# Create the App Runner service.
resource "aws_apprunner_service" "service" {
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.auto_scaling_config.arn
  service_name                   = var.service_name
  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.deploy_role.arn
    }
    image_repository {
      image_identifier      = "${var.image_repository}:${var.image_tag}"
      image_repository_type = "ECR"
      image_configuration {
        port                          = tostring(var.port)
        runtime_environment_variables = var.environment_variables
        start_command                 = var.start_command
      }
    }
    auto_deployments_enabled = true
  }
  instance_configuration {
    cpu               = var.instance_cpu
    memory            = var.instance_memory
    instance_role_arn = aws_iam_role.instance_role.arn
  }
  health_check_configuration {
    path                = var.health_check_endpoint
    protocol            = "HTTP"
    healthy_threshold   = 1  # One healthy response is sufficient to determine the instance is healthy.
    interval            = 6  # Check health every 6 seconds.
    unhealthy_threshold = 10 # Instance is replaced after 10 consecutive unhealthy responses, over 10 * 6 seconds.
  }
}

# Associate a domain name with the App Runner service.
resource "aws_apprunner_custom_domain_association" "domain_association" {
  count = var.domain_name == null ? 0 : 1
  domain_name = var.domain_name
  enable_www_subdomain = false
  service_arn = aws_apprunner_service.service.arn
}

# Validate the domain name with DNS validation records.
resource "aws_route53_record" "domain_name_validation" {
  count           = var.domain_name == null ? 0 : 2
  allow_overwrite = true
  name            = element(aws_apprunner_custom_domain_association.domain_association[0].certificate_validation_records[*].name, count.index)
  records         = [element(aws_apprunner_custom_domain_association.domain_association[0].certificate_validation_records[*].value, count.index)]
  ttl             = 60
  type            = element(aws_apprunner_custom_domain_association.domain_association[0].certificate_validation_records[*].type, count.index)
  zone_id         = var.hosted_zone_id
}

# Associate the domain name with the App Runner service.
resource "aws_route53_record" "dns_target" {
  count           = var.domain_name == null ? 0 : 1
  allow_overwrite = true
  name            = var.domain_name
  records         = [aws_apprunner_custom_domain_association.domain_association[0].dns_target]
  ttl             = 3600
  type            = "CNAME"
  zone_id         = var.hosted_zone_id
}
