variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name"
  type        = string
}

variable "subdomain_name" {
  description = "Project name"
  type        = string
}

variable "bastion_allow_ips" {
  description = "List of IP addresses to allow to bastion host"
  type        = list(string)
}

variable "app_allow_ips" {
  description = "List of IP addresses to allow to application"
  type        = list(string)
}

variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
  sensitive   = true
}

variable "django_superuser_name" {
  description = "Django superuser name"
  type        = string
  sensitive   = true
}

variable "django_superuser_email" {
  description = "Django superuser email"
  type        = string
  sensitive   = true
}

variable "django_superuser_password" {
  description = "Django superuser password"
  type        = string
  sensitive   = true
}

variable "tf_state_bucket_name" {
  description = "The name of the S3 bucket for storing Terraform state"
  type        = string
}











