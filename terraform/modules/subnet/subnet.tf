##############################
## Database Subnets

resource "aws_subnet" "private_1a" {
  cidr_block              = var.private_cidr_block_1a
  map_public_ip_on_launch = false
  vpc_id                  = var.aws_vpc_id
  availability_zone       = "${var.aws_region}a"
}

resource "aws_subnet" "private_1b" {
  cidr_block              = var.private_cidr_block_1b
  map_public_ip_on_launch = false
  vpc_id                  = var.aws_vpc_id
  availability_zone       = "${var.aws_region}b"
}

resource "aws_route_table" "private" {
  vpc_id = var.aws_vpc_id
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_1b" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private.id
}

##############################
## Public Subnets for Application Load Balancer

resource "aws_subnet" "public_1a" {
  cidr_block              = var.public_cidr_block_1a
  map_public_ip_on_launch = true
  vpc_id                  = var.aws_vpc_id
  availability_zone       = "${var.aws_region}a"
}

resource "aws_subnet" "public_1b" {
  cidr_block              = var.public_cidr_block_1b
  map_public_ip_on_launch = true
  vpc_id                  = var.aws_vpc_id
  availability_zone       = "${var.aws_region}b"
}

resource "aws_route_table" "public" {
  vpc_id = var.aws_vpc_id
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.aws_vpc_id
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

##############################
## NAT Gateway

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1a.id
}

resource "aws_route" "private_internet_out" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}