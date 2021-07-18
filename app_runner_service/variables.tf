variable "service_name" {
  description = "The name of the service hosted by App Runner."
  type        = string
}

variable "hosted_zone_id" {
  description = "The hosted zone id that manages the domain name's DNS."
  type        = string
  default     = null
}

variable "domain_name" {
  description = "The domain name to associate with the App Runner service."
  type        = string
  default     = null
}

variable "image_repository" {
  description = "The URL of the Docker image repository that hosts the Docker images used by App Runner. If omitted, an ECR repository will be created by this module."
  type        = string
}

variable "image_tag" {
  description = "The Docker image tag to deploy."
  type        = string
}

variable "start_command" {
  description = "The Docker command to start the service."
  type        = string
  default     = null
}

variable "health_check_endpoint" {
  description = "The endpoint to poll to check whether an instance is healthy."
  type        = string
  default     = "/healthcheck"
}

variable "environment_variables" {
  description = "A map of environment variables to set in the service."
  type        = map(string)
  default     = {}
}

variable "instance_cpu" {
  description = "The number of CPU units reserved for each instance of your App Runner service."
  type        = string
  default     = "1 vCPU"
}

variable "instance_memory" {
  description = "The amount of memory, in MB or GB, reserved for each instance of your App Runner service."
  type        = string
  default     = "2 GB"
}

variable "max_concurrency_per_instance" {
  description = "The maximal number of concurrent requests that you want an instance to process. When the number of concurrent requests goes over this limit, App Runner scales up your service."
  type        = number
  default     = 50
}

variable "min_instances" {
  description = "The minimal number of instances that App Runner provisions for your service."
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "The maximal number of instances that App Runner provisions for your service."
  type        = number
  default     = 10
}

variable "port" {
  description = "The port to expose. The default port that gunicorn and uvicorn use is 8000."
  type        = number
  default     = 8000
}
