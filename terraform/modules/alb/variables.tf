variable "alb_name" {
  description = "The name of the application load balancer."
  type        = string
  default     = "app-lb"
}

variable "health_check_path" {
  description = "The path for the health check."
  type        = string
  default     = "/healthcheck"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the load balancer."
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the load balancer."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the resources will be deployed."
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS listener."
  type        = string
}