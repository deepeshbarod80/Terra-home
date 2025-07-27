module "vpc" {
  source              = "../../modules/vpc"
  environment         = "pre-prod"
  region              = "us-west-2"
  vpc_cidr            = "10.1.0.0/16"
  public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
  database_subnet_cidrs = ["10.1.5.0/24", "10.1.6.0/24"]
  availability_zones  = ["us-west-2a", "us-west-2b"]
  trusted_ip          = "203.0.113.0/24"
  transit_gateway_id  = var.transit_gateway_id
  flow_log_role_arn   = module.security.flow_logs_role_arn
  flow_log_destination = module.security.flow_logs_destination
}

module "security" {
  source      = "../../modules/security"
  environment = "pre-prod"
  vpc_id      = module.vpc.vpc_id
}

module "eks" {
  source            = "../../modules/eks"
  environment       = "pre-prod"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr
  private_subnet_ids = module.vpc.private_subnet_ids
  kubernetes_version = "1.28"
  kms_key_arn       = module.security.kms_key_arn
  
  node_groups = {
    app = {
      instance_types = ["m5.large"]
      desired_size   = 2
      max_size       = 4
      min_size       = 2
      labels = {
        "role" = "app"
      }
    }
    monitoring = {
      instance_types = ["t3.large"]
      desired_size   = 1
      max_size       = 2
      min_size       = 1
      labels = {
        "role" = "monitoring"
      }
    }
  }
}

module "load_balancer" {
  source            = "../../modules/load_balancer"
  environment       = "pre-prod"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  waf_web_acl_arn   = module.security.waf_web_acl_arn
}