variable "lambda_name" {
  description = "name for lambda"
  type        = string
}

variable "lambda_security_group_id" {
  description = "ID of the Lambda security group"
  type        = string
}

variable "environment_name" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for Lambda VPC config"
  type        = list(string)
}

variable "lambda_image_uri" {
  description = "URI of the Lambda container image"
  type        = string
}

variable "lambda_image_tag" {
  description = "Tag of the Lambda container image"
  type        = string
}

variable "ssm_parameter_arns" {
  description = "Map of SSM parameter ARNs"
  type        = map(string)
}

variable "sqs_queue_arns" {
  description = "Map of SQS queue ARNs (queue and dead-letter queue)"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID for Lambda VPC config"
  type        = string
}