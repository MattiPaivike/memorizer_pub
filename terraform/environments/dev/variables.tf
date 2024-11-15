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