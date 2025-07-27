module "vpc" {
  source              = "../../modules/vpc"
  environment         = "shared-services"
  region              = "us-east-1"
  vpc_cidr            = "10.4.0.0/16"
  public_subnet_cidrs = ["10.4.1.0/24", "10.4.2.0/24"]
  private_subnet_cidrs = ["10.4.3.0/24", "10.4.4.0/24"]
  database_subnet_cidrs = ["10.4.5.0/24", "10.4.6.0/24"]
  availability_zones  = ["us-east-1a", "us-east-1b"]
  trusted_ip          = "203.0.113.0/24"
  transit_gateway_id  = var.transit_gateway_id
  flow_log_role_arn   = module.security.flow_logs_role_arn
  flow_log_destination = module.security.flow_logs_destination
}

module "security" {
  source      = "../../modules/security"
  environment = "shared-services"
  vpc_id      = module.vpc.vpc_id
}

module "eks" {
  source            = "../../modules/eks"
  environment       = "shared-services"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr
  private_subnet_ids = module.vpc.private_subnet_ids
  kubernetes_version = "1.28"
  kms_key_arn       = module.security.kms_key_arn
  
  node_groups = {
    services = {
      instance_types = ["m5.large"]
      desired_size   = 2
      max_size       = 4
      min_size       = 2
      labels = {
        "role" = "services"
      }
    }
    monitoring = {
      instance_types = ["m5.large"]
      desired_size   = 1
      max_size       = 2
      min_size       = 1
      labels = {
        "role" = "monitoring"
      }
    }
  }
}

# Shared ECR repositories
module "ecr" {
  source      = "../../modules/ecr"
  environment = "shared-services"
}

# Centralized monitoring
module "monitoring" {
  source      = "../../modules/monitoring"
  environment = "shared-services"
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = module.vpc.vpc_cidr
}