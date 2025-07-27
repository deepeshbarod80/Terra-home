variable "environment" {
  type        = string
  description = "Environment name (dev, stage, pre-prod, prod, shared-services)"
}

variable "region" {
  type        = string
  description = "AWS region for monitoring resources"
  default     = "us-east-1"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for monitoring resources"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of KMS key for encryption"
  default     = ""
}