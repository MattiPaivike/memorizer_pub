module "certificate" {
  source         = "../../modules/certificate"
  subdomain_name = var.subdomain_name
  domain_name    = var.domain_name
}