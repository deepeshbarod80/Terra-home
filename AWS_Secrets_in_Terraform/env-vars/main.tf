terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_secretsmanager_secret" "example" {
  name        = "example-secret-env-vars"
  description = "Example secret using environment variables authentication"
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