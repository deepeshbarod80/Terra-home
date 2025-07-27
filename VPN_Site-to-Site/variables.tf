variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_private_subnet_cidr" {
  description = "CIDR block for AWS private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_subnet_cidr" {
  description = "CIDR block for GCP subnet"
  type        = string
  default     = "192.168.0.0/24"
}