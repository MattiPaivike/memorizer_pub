variable "domain_name" {
  description = "Primary domain name for A record"
  type        = string
}

variable "subdomain_name" {
  description = "Subdomain name for A record"
  type        = string
}

variable "lb_dns_name" {
  description = "DNS name of the load balancer"
  type        = string
}

variable "lb_zone_id" {
  description = "Zone ID of the load balancer"
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the certificate"
  type        = string
}

variable "certificate_app_validations" {
  description = "Map of certificate validation options"
}