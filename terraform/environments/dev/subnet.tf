module "subnet" {
  source     = "../../modules/subnet"
  aws_vpc_id = data.terraform_remote_state.common.outputs.vpc_id
  prefix     = "dev"
  aws_region = var.aws_region
}