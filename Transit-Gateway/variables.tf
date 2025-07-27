variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "trusted_ip" {
  type        = string
  description = "CIDR block for trusted IP addresses"
  default     = "203.0.113.0/24"  # Example IP, replace with your actual trusted IP
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for EKS clusters"
  default     = "1.28"
}