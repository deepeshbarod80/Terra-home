variable "environment" {
  type        = string
  description = "Environment name (dev, stage, pre-prod, prod, shared-services)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security resources"
  default     = ""
}