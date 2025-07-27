variable "environment" {
  type        = string
  description = "Environment name (dev, stage, pre-prod, prod, shared-services)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS cluster will be created"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for EKS cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for EKS cluster"
  default     = "1.28"
}

variable "endpoint_public_access" {
  type        = bool
  description = "Whether to enable public API endpoint"
  default     = false
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of KMS key for EKS secrets encryption"
  default     = ""
}

variable "node_groups" {
  type = map(object({
    instance_types = optional(list(string), ["t3.medium"])
    ami_type       = optional(string, "AL2_x86_64")
    capacity_type  = optional(string, "ON_DEMAND")
    disk_size      = optional(number, 50)
    desired_size   = optional(number, 2)
    max_size       = optional(number, 4)
    min_size       = optional(number, 1)
    max_unavailable = optional(number, 1)
    labels         = optional(map(string), {})
  }))
  description = "Map of EKS node groups to create"
  default = {
    "app" = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      max_size       = 4
      min_size       = 1
    }
  }
}

variable "create_fargate_profile" {
  type        = bool
  description = "Whether to create a Fargate profile"
  default     = false
}