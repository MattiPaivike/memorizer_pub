variable "prefix" {
  description = "Name of the environment (e.g., dev, prod)"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the bastion instance"
  type        = string
  default     = "t3.micro"
}

variable "bastion_connections_security_groups" {
  description = "List of security groups to allow connections to and from bastion"
  type        = list(string)
}

variable "instance_name" {
  description = "Name for the bastion instance"
  type        = string
  default     = "bastion"
}

variable "ssh_key_name" {
  description = "SSH key name to use for the bastion instance"
  type        = string
}

variable "bastion_allowed_ips" {
  description = "CIDR blocks allowed to access the bastion"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID to associate with the bastion's security group"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the bastion instance will be launched"
  type        = string
}