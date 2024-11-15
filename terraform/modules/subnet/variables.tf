
variable "aws_vpc_id" {
  description = "id of the VPC"
  type        = string
}

variable "prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "private_cidr_block_1a" {
  description = "CIDR block for private subnet in availability zone 1a"
  type        = string
  default     = "10.177.10.0/24"
}

variable "private_cidr_block_1b" {
  description = "CIDR block for private subnet in availability zone 1b"
  type        = string
  default     = "10.177.20.0/24"
}

variable "public_cidr_block_1a" {
  description = "CIDR block for public subnet in availability zone 1a"
  type        = string
  default     = "10.177.1.0/24"
}

variable "public_cidr_block_1b" {
  description = "CIDR block for public subnet in availability zone 1b"
  type        = string
  default     = "10.177.2.0/24"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"

}