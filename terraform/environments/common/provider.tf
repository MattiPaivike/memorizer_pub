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
    bucket         = "epicmemory-tf-state12351531351341"
    key            = "common/epicmemory.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "epicmemory-tf-state-lock"
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}