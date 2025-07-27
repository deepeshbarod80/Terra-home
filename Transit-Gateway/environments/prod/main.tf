module "vpc" {
  source              = "../../modules/vpc"
  environment         = "prod"
  region              = "us-east-1"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  database_subnet_cidrs = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  trusted_ip          = "203.0.113.0/24"
  transit_gateway_id  = var.transit_gateway_id
  flow_log_role_arn   = module.security.flow_logs_role_arn
  flow_log_destination = module.security.flow_logs_destination
}

module "security" {
  source      = "../../modules/security"
  environment = "prod"
  vpc_id      = module.vpc.vpc_id
}

module "eks" {
  source            = "../../modules/eks"
  environment       = "prod"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr
  private_subnet_ids = module.vpc.private_subnet_ids
  kubernetes_version = "1.28"
  kms_key_arn       = module.security.kms_key_arn
  
  node_groups = {
    app = {
      instance_types = ["m5.xlarge"]
      desired_size   = 3
      max_size       = 6
      min_size       = 3
      labels = {
        "role" = "app"
      }
    }
    monitoring = {
      instance_types = ["m5.large"]
      desired_size   = 2
      max_size       = 3
      min_size       = 2
      labels = {
        "role" = "monitoring"
      }
    }
    batch = {
      instance_types = ["c5.large"]
      desired_size   = 1
      max_size       = 4
      min_size       = 0
      labels = {
        "role" = "batch"
      }
    }
  }
}

module "load_balancer" {
  source            = "../../modules/load_balancer"
  environment       = "prod"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  waf_web_acl_arn   = module.security.waf_web_acl_arn
}