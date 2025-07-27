variable "region" {
  type        = string
  description = "AWS region for the Transit Gateway"
  default     = "us-east-1"
}

variable "amazon_side_asn" {
  type        = number
  description = "ASN for the Amazon side of the Transit Gateway"
  default     = 64512
}

variable "vpc_attachments" {
  type = map(object({
    vpc_id     = string
    subnet_ids = list(string)
    vpc_cidr   = string
  }))
  description = "Map of VPC attachments for the Transit Gateway"
}

variable "tgw_peering_connections" {
  type = map(object({
    peer_account_id         = string
    peer_region             = string
    peer_transit_gateway_id = string
  }))
  description = "Map of Transit Gateway peering connections"
  default     = {}
}

variable "ram_principals" {
  type        = list(string)
  description = "List of AWS account IDs to share the Transit Gateway with"
  default     = []
}