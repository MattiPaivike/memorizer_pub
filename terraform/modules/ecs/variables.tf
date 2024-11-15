variable "prefix" {
  description = "Environment name for the deployment (e.g., dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for ECS logging"
  type        = string
  default     = "eu-north-1"
}

variable "sqs_queue_id" {
  description = "SQS queue ID to pass to Django application via environment variable"
  type        = string
}

variable "ecr_repository_url_django" {
  description = "URL of the ECR repository for Django application"
  type        = string
}

variable "django_ecr_tag" {
  description = "tag of the ECR repository for Django application"
  type        = string
  default     = "latest"
}

variable "ecr_repository_url_nginx" {
  description = "URL of the ECR repository for Nginx"
  type        = string
}

variable "nginx_ecr_tag" {
  description = "tag of the ECR repository for Nginx"
  type        = string
  default     = "latest"
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue to give ECS sendmessage rights"
  type        = string
}

variable "container_mount_location" {
  description = "Location to mount the container. Used with static files between django and nginx"
  type        = string
  default     = "/vol/web"
}

variable "load_balancer_target_group_arn" {
  description = "ARN of the load balancer target group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to use for the ECS service"
  type        = string
}

variable "subnets" {
  description = "Subnets to use for the ECS service"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups to associate with the ECS service"
  type        = list(string)
}

variable "ssm_parameter_arns" {
  description = "list of SSM parameter ARNs to attach to ECS policy for reading rights"
  type        = list(string)
}

variable "service_secrets" {
  description = "Map of secret keys with corresponding SSM parameter ARNs"
  type        = map(string)
  # example of how to use this variable in the module
  #   default = {
  #     SECRET_KEY    = aws_ssm_parameter.django_secret_key.arn,
  #     DB_HOST       = aws_ssm_parameter.db_host.arn,
  #     DB_NAME       = aws_ssm_parameter.db_name.arn,
  #     DB_USER       = aws_ssm_parameter.db_username.arn,
  #     DB_PASS       = aws_ssm_parameter.db_pass.arn,
  #     ALLOWED_HOSTS = aws_ssm_parameter.django_allowed_hosts.arn
  #   }
}