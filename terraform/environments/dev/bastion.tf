module "bastion" {
  source                              = "../../modules/bastion"
  prefix                              = "dev"
  ssh_key_name                        = "memorizer-bastion-key"
  bastion_allowed_ips                 = ["192.130.196.210/32"]
  vpc_id                              = data.terraform_remote_state.common.outputs.vpc_id
  subnet_id                           = module.subnet.public_subnet_ids[0]
  bastion_connections_security_groups = [module.bastion_sg_rds.security_group_id, module.bastion_sg_connection.security_group_id]
}