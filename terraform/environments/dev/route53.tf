module "route53" {
  source                      = "../../modules/route53"
  domain_name                 = var.domain_name
  subdomain_name              = var.subdomain_name
  certificate_arn             = module.certificate.certificate_arn
  certificate_app_validations = module.certificate.validation_options
  lb_dns_name                 = module.alb.load_balancer_dns_name
  lb_zone_id                  = module.alb.load_balancer_zone_id
}
