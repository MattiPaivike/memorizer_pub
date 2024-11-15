module "rds" {
  source                 = "../../modules/rds"
  rds_name               = "dev-memorizer"
  vpc_id                 = data.terraform_remote_state.common.outputs.vpc_id
  subnet_ids             = module.subnet.private_subnet_ids
  rds_db_name            = "memorizer"
  db_username            = "memorizer"
  rds_security_group_ids = [module.db_sg.security_group_id]
}
