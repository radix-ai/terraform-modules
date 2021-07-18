output "instance_role_name" {
  value = local.instance_role_name
}

output "service_url" {
  value = aws_apprunner_service.service.service_url
}
