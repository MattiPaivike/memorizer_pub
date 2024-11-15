output "rds_instance_endpoint" {
  description = "The RDS instance endpoint"
  value       = aws_db_instance.rds.endpoint
}

output "rds_db_subnet_group_name" {
  description = "The name of the RDS DB subnet group"
  value       = aws_db_subnet_group.db_subnet_group.name
}

output "db_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.rds.address
}

output "db_username" {
  description = "The username for the RDS instance"
  value       = aws_db_instance.rds.username
}

output "db_name" {
  description = "The name of the RDS database"
  value       = aws_db_instance.rds.db_name
}

output "db_password" {
  description = "The password for the RDS database"
  value       = random_password.db.result
}