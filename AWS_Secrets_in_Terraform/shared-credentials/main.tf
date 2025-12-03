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
  shared_credentials_files = [var.shared_credentials_file]
  profile                  = var.aws_profile
}

resource "aws_secretsmanager_secret" "example" {
  name        = "example-secret-shared-creds"
  description = "Example secret using shared credentials authentication"
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