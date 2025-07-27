variable "environment" {
  type        = string
  description = "Environment name (dev, stage, pre-prod, prod, shared-services)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the load balancer"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for the load balancer"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for internal load balancers"
}

variable "internal" {
  type        = bool
  description = "Whether the load balancer is internal"
  default     = false
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the SSL certificate for HTTPS listeners"
  default     = ""
}

variable "waf_web_acl_arn" {
  type        = string
  description = "ARN of the WAF Web ACL to associate with the load balancer"
  default     = ""
}