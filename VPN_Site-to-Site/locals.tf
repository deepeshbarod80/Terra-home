locals {
  common_tags = {
    Environment = "Production"
    Project     = "AWS-GCP-VPN"
    ManagedBy   = "Terraform"
  }
  
  # Tunnel configuration parameters
  tunnel_inside_cidr = "169.254.21.0/30"
  
  # Default AWS region AZs
  aws_azs = ["${var.aws_region}a", "${var.aws_region}b"]
}