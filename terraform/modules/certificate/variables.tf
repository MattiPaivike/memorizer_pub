variable "subdomain_name" {
  description = "The name of the project. This will be appended to domain name as var.project_name.mydomain.com."
  type        = string
}

variable "domain_name" {
  description = "The domain name of the project."
  type        = string

}
