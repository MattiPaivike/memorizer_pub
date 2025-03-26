module "ecs" {
  source                         = "../../modules/ecs"
  prefix                         = "dev-memorizer"
  ecr_repository_url_django      = data.terraform_remote_state.common.outputs.django_ecr_repository_url
  django_ecr_tag                 = "latest"
  ecr_repository_url_nginx       = data.terraform_remote_state.common.outputs.nginx_ecr_repository_url
  nginx_ecr_tag                  = "latest"
  load_balancer_target_group_arn = module.alb.target_group_arn
  vpc_id                         = data.terraform_remote_state.common.outputs.vpc_id
  subnets                        = module.subnet.private_subnet_ids
  security_groups                = [module.ecs_service_sg.security_group_id]
  aws_region                     = var.aws_region
  ssm_parameter_arns = [
    module.ssm_django_secret_key.ssm_parameter_arn,
    module.ssm_django_allowed_hosts.ssm_parameter_arn,
    module.ssm_db_host.ssm_parameter_arn,
    module.ssm_db_name.ssm_parameter_arn,
    module.ssm_db_username.ssm_parameter_arn,
    module.ssm_db_pass.ssm_parameter_arn,
    module.ssm_django_superuser_name.ssm_parameter_arn,
    module.ssm_django_superuser_email.ssm_parameter_arn,
    module.ssm_django_superuser_password.ssm_parameter_arn
  ]
  service_secrets = {
    SECRET_KEY    = "${module.ssm_django_secret_key.ssm_parameter_arn}",
    DB_HOST       = "${module.ssm_db_host.ssm_parameter_arn}",
    DB_NAME       = "${module.ssm_db_name.ssm_parameter_arn}",
    DB_USER       = "${module.ssm_db_username.ssm_parameter_arn}",
    DB_PASS       = "${module.ssm_db_pass.ssm_parameter_arn}",
    ALLOWED_HOSTS = "${module.ssm_django_allowed_hosts.ssm_parameter_arn}"
    DJANGO_SUPERUSER_NAME = "${module.ssm_django_superuser_name.ssm_parameter_arn}"
    DJANGO_SUPERUSER_EMAIL = "${module.ssm_django_superuser_email.ssm_parameter_arn}"
    DJANGO_SUPERUSER_PASSWORD = "${module.ssm_django_superuser_password.ssm_parameter_arn}"
  }
  sqs_queue_arn = module.sqs.sqs_queue_arn
  sqs_queue_id  = module.sqs.sqs_queue_id
}