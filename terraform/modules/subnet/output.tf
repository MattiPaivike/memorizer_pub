output "vpc_id" {
  value = var.aws_vpc_id
}

output "private_subnet_ids" {
  value = [aws_subnet.private_1a.id, aws_subnet.private_1b.id]
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
}

output "private_subnet_cidr_blocks" {
  value = [aws_subnet.private_1a.cidr_block, aws_subnet.private_1b.cidr_block]
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}
