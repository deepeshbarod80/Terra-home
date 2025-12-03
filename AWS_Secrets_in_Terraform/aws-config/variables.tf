variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_config_file" {
  description = "Path to AWS config file"
  type        = string
  default     = "~/.aws/config"
}

variable "aws_credentials_file" {
  description = "Path to AWS credentials file"
  type        = string
  default     = "~/.aws/credentials"
}