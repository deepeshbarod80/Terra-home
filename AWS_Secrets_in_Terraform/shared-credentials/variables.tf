variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "shared_credentials_file" {
  description = "Path to shared credentials file"
  type        = string
  default     = "~/.aws/credentials"
}

variable "aws_profile" {
  description = "AWS profile name"
  type        = string
  default     = "default"
}