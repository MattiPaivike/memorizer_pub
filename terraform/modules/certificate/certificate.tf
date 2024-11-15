resource "aws_acm_certificate" "app" {
  domain_name       = "${var.subdomain_name}.${var.domain_name}"
  validation_method = "DNS"
}

locals {
  validation_options = [
    for dvo in aws_acm_certificate.app.domain_validation_options : {
      domain_name = dvo.domain_name
      name        = dvo.resource_record_name
      record      = dvo.resource_record_value
      type        = dvo.resource_record_type
    }
  ]
}
