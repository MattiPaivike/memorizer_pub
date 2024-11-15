resource "aws_vpc" "vpc" {
  enable_dns_hostnames = true
  cidr_block           = var.vpc_cidr_block
}