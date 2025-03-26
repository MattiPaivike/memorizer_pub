module "subnet" {
  source     = "../../modules/subnet"
  aws_vpc_id = data.terraform_remote_state.common.outputs.vpc_id
  prefix     = "dev"
  aws_region = var.aws_region
  private_cidr_block_1a = "10.200.10.0/24"
  private_cidr_block_1b = "10.200.20.0/24"
  public_cidr_block_1a = "10.200.1.0/24"
  public_cidr_block_1b = "10.200.2.0/24"
}