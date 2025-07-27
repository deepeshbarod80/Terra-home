variable "environment" {
  type        = string
  description = "Environment name (dev, stage, pre-prod, prod, shared-services)"
}

variable "region" {
  type        = string
  description = "AWS region for the VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
}

variable "database_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for database subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "trusted_ip" {
  type        = string
  description = "CIDR block for trusted IP addresses"
}

variable "transit_gateway_id" {
  type        = string
  description = "ID of the Transit Gateway for VPC attachment"
  default     = ""
}

variable "flow_log_role_arn" {
  type        = string
  description = "IAM role ARN for VPC flow logs"
  default     = ""
}

variable "flow_log_destination" {
  type        = string
  description = "CloudWatch log group for VPC flow logs"
  default     = ""
}