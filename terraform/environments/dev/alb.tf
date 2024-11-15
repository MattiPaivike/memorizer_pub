module "alb" {
  source             = "../../modules/alb"
  alb_name           = "dev-alb"
  health_check_path  = "/healthcheck"
  subnet_ids         = module.subnet.public_subnet_ids
  security_group_ids = [module.lb_sg.security_group_id]
  vpc_id             = data.terraform_remote_state.common.outputs.vpc_id
  certificate_arn    = module.certificate.certificate_arn
}