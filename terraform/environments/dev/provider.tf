provider "aws" {
  region = "eu-north-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.19.0"
    }
  }
}

terraform {
  backend "s3" {
    key            = "dev/epicmemory.tfstate"
    encrypt        = true
  }
}

data "terraform_remote_state" "common" {
  backend = "s3"
  config = {
    bucket = var.tf_state_bucket_name
    key    = "common/epicmemory.tfstate"
    region = var.aws_region
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}