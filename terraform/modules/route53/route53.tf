data "aws_route53_zone" "primary" {
  name = var.domain_name
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${var.subdomain_name}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}

locals {
  validation_options = [
    for dvo in tolist(var.certificate_app_validations) : {
      domain_name = dvo.domain_name
      name        = dvo.resource_record_name
      record      = dvo.resource_record_value
      type        = dvo.resource_record_type
    }
  ]
}

resource "aws_route53_record" "app_certificate_validation" {
  for_each = { for obj in local.validation_options : obj.domain_name => obj }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary.zone_id
}

resource "aws_acm_certificate_validation" "app" {
  certificate_arn         = var.certificate_arn
  validation_record_fqdns = [for record in aws_route53_record.app_certificate_validation : record.fqdn]
}