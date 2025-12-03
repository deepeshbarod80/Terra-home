terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                   = var.aws_region
  shared_config_files      = [var.aws_config_file]
  shared_credentials_files = [var.aws_credentials_file]
}

resource "aws_secretsmanager_secret" "example" {
  name        = "example-secret-aws-config"
  description = "Example secret using AWS config file authentication"
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id = aws_secretsmanager_secret.example.id
  secret_string = jsonencode({
    username = "admin"
    password = "supersecret123"
  })
}

data "aws_secretsmanager_secret_version" "example" {
  secret_id = aws_secretsmanager_secret.example.id
}