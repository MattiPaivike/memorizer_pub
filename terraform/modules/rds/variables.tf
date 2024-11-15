variable "rds_name" {
  description = "The name of the RDS database instance"
  type        = string
}

variable "rds_security_group_ids" {
  description = "List of security group IDs to place RDS in"
  type        = list(string)
}

variable "rds_db_name" {
  description = "The name of the RDS database"
  type        = string
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "postgres"
}

variable "vpc_id" {
  description = "The ID of the VPC where RDS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "db_instance_class" {
  description = "Instance class for the RDS database instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in gigabytes for the RDS database"
  type        = number
  default     = 10
}

variable "db_backup_retention" {
  description = "Number of days to retain RDS backups"
  type        = number
  default     = 7
}

variable "db_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}
