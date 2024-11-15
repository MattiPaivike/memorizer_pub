module "lambda_sg" {
  source      = "../../modules/security_group"
  name        = "dev-memorizer-consumer-db-sg-lambda"
  description = "Allow access to the RDS database instance."
  vpc_id      = data.terraform_remote_state.common.outputs.vpc_id

  egress_rules = {
    "all_outbound" = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

module "bastion_sg_connection" {
  source      = "../../modules/security_group"
  name        = "dev-bastion-security-group-connection"
  description = "Allow SSH access to bastion host, outbound internet access"
  vpc_id      = data.terraform_remote_state.common.outputs.vpc_id

  ingress_rules = {
    "ssh_access" = {
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = var.bastion_allow_ips
    }
  }

  egress_rules = {
    "https_access" = {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["0.0.0.0/0"]
    }
    "http_access" = {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}


module "bastion_sg_rds" {
  source      = "../../modules/security_group"
  name        = "dev-bastion-security-group-database"
  description = "bastion host allow postgres access."
  vpc_id      = data.terraform_remote_state.common.outputs.vpc_id
  egress_rules = {
    "postgres_access" = {
      protocol    = "tcp"
      from_port   = 5432
      to_port     = 5432
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

module "db_sg" {
  source      = "../../modules/security_group"
  name        = "dev-db-sg-rds-"
  description = "Allow access to the RDS database instance."
  vpc_id      = data.terraform_remote_state.common.outputs.vpc_id

  ingress_rules = {
    "db_access_lambda" = {
      description = "dev allow access to db lambda"
      protocol    = "tcp"
      from_port   = 5432
      to_port     = 5432
      security_group = module.lambda_sg.security_group_id
      cidr_blocks = []
    }
    "db_access_bastion" = {
      description = "dev allow access to db bastion"
      protocol    = "tcp"
      from_port   = 5432
      to_port     = 5432
      security_group = module.bastion_sg_rds.security_group_id
      cidr_blocks = []
    }
    "db_access_ecs" = {
      description = "dev allow access to db ecs"
      protocol    = "tcp"
      from_port   = 5432
      to_port     = 5432
      security_group = module.ecs_service_sg.security_group_id
      cidr_blocks = []
    }
  }
}

module "lb_sg" {
  source      = "../../modules/security_group"
  name        = "dev-django-loadbalancer-sg"
  description = "Allow access to Application Load Balancer"
  vpc_id      = data.terraform_remote_state.common.outputs.vpc_id

  ingress_rules = {
    "app_access" = {
      cidr_blocks = var.app_allow_ips
      description = "Allowed IP addresses to connect to application"
      from_port   = 443
      protocol    = "tcp"
      to_port     = 443
    }
  }

  egress_rules = {
    "app_outbound" = {
      protocol    = "tcp"
      from_port   = 8000
      to_port     = 8000
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

module "ecs_service_sg" {
  source      = "../../modules/security_group"
  name        = "dev-memorizer-django-ecs-service"
  description = "DEV: Allow access to the memorizer Django ECS service"
  vpc_id      = data.terraform_remote_state.common.outputs.vpc_id

  ingress_rules = {
    "ecs_service_ingress" = {
      from_port       = 8000
      to_port         = 8000
      protocol        = "tcp"
      security_group = module.lb_sg.security_group_id
      cidr_blocks     = []
    }
  }

  egress_rules = {
    "https_outbound" = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    "db_outbound" = {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = module.subnet.private_subnet_cidr_blocks
    }
  }
}
