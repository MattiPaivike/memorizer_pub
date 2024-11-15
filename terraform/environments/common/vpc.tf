module "vpc" {
  source         = "../../modules/vpc"
  vpc_cidr_block = "10.177.0.0/16"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}