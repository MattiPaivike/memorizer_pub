resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.rds_name}-db-subnet-"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "rds" {
  identifier              = var.rds_name
  db_name                 = var.rds_db_name
  storage_type            = "gp2"
  engine                  = "postgres"
  allocated_storage       = var.db_allocated_storage
  instance_class          = var.db_instance_class
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  password                = random_password.db.result
  username                = var.db_username
  backup_retention_period = var.db_backup_retention
  multi_az                = var.db_multi_az
  skip_final_snapshot     = false
  vpc_security_group_ids  = var.rds_security_group_ids
}


resource "random_password" "db" {
  length           = 16
  special          = true
  override_special = "_!%^"
}