provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "us-west-2"
}

provider "aws" {
  region = "eu-west-1"
  alias  = "eu-west-1"
}

provider "aws" {
  region = "ap-south-1"
  alias  = "ap-south-1"
}

# Transit Gateway in us-east-1 (central region)
module "transit_gateway" {
  source = "./modules/transit_gateway"
  region = "us-east-1"
  
  vpc_attachments = {
    prod = {
      vpc_id     = module.prod_vpc.vpc_id
      subnet_ids = module.prod_vpc.private_subnet_ids
      vpc_cidr   = "10.0.0.0/16"
    }
    pre-prod = {
      vpc_id     = module.pre_prod_vpc.vpc_id
      subnet_ids = module.pre_prod_vpc.private_subnet_ids
      vpc_cidr   = "10.1.0.0/16"
    }
    stage = {
      vpc_id     = module.stage_vpc.vpc_id
      subnet_ids = module.stage_vpc.private_subnet_ids
      vpc_cidr   = "10.2.0.0/16"
    }
    dev = {
      vpc_id     = module.dev_vpc.vpc_id
      subnet_ids = module.dev_vpc.private_subnet_ids
      vpc_cidr   = "10.3.0.0/16"
    }
    shared-services = {
      vpc_id     = module.shared_services_vpc.vpc_id
      subnet_ids = module.shared_services_vpc.private_subnet_ids
      vpc_cidr   = "10.4.0.0/16"
    }
  }
}

# Production VPC in us-east-1
module "prod_vpc" {
  source              = "./modules/vpc"
  providers           = { aws = aws.us-east-1 }
  environment         = "prod"
  region              = "us-east-1"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  database_subnet_cidrs = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  trusted_ip          = "203.0.113.0/24"
}

# Pre-Production VPC in us-west-2
module "pre_prod_vpc" {
  source              = "./modules/vpc"
  providers           = { aws = aws.us-west-2 }
  environment         = "pre-prod"
  region              = "us-west-2"
  vpc_cidr            = "10.1.0.0/16"
  public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
  database_subnet_cidrs = ["10.1.5.0/24", "10.1.6.0/24"]
  availability_zones  = ["us-west-2a", "us-west-2b"]
  trusted_ip          = "203.0.113.0/24"
}

# Staging VPC in eu-west-1
module "stage_vpc" {
  source              = "./modules/vpc"
  providers           = { aws = aws.eu-west-1 }
  environment         = "stage"
  region              = "eu-west-1"
  vpc_cidr            = "10.2.0.0/16"
  public_subnet_cidrs = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnet_cidrs = ["10.2.3.0/24", "10.2.4.0/24"]
  database_subnet_cidrs = ["10.2.5.0/24", "10.2.6.0/24"]
  availability_zones  = ["eu-west-1a", "eu-west-1b"]
  trusted_ip          = "203.0.113.0/24"
}

# Development VPC in ap-south-1
module "dev_vpc" {
  source              = "./modules/vpc"
  providers           = { aws = aws.ap-south-1 }
  environment         = "dev"
  region              = "ap-south-1"
  vpc_cidr            = "10.3.0.0/16"
  public_subnet_cidrs = ["10.3.1.0/24", "10.3.2.0/24"]
  private_subnet_cidrs = ["10.3.3.0/24", "10.3.4.0/24"]
  database_subnet_cidrs = ["10.3.5.0/24", "10.3.6.0/24"]
  availability_zones  = ["ap-south-1a", "ap-south-1b"]
  trusted_ip          = "203.0.113.0/24"
}

# Shared Services VPC in us-east-1
module "shared_services_vpc" {
  source              = "./modules/vpc"
  providers           = { aws = aws.us-east-1 }
  environment         = "shared-services"
  region              = "us-east-1"
  vpc_cidr            = "10.4.0.0/16"
  public_subnet_cidrs = ["10.4.1.0/24", "10.4.2.0/24"]
  private_subnet_cidrs = ["10.4.3.0/24", "10.4.4.0/24"]
  database_subnet_cidrs = ["10.4.5.0/24", "10.4.6.0/24"]
  availability_zones  = ["us-east-1a", "us-east-1b"]
  trusted_ip          = "203.0.113.0/24"
}

# EKS clusters in each environment
module "prod_eks" {
  source            = "./modules/eks"
  providers         = { aws = aws.us-east-1 }
  environment       = "prod"
  vpc_id            = module.prod_vpc.vpc_id
  vpc_cidr          = module.prod_vpc.vpc_cidr
  private_subnet_ids = module.prod_vpc.private_subnet_ids
  kubernetes_version = "1.28"
  
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

module "pre_prod_eks" {
  source            = "./modules/eks"
  providers         = { aws = aws.us-west-2 }
  environment       = "pre-prod"
  vpc_id            = module.pre_prod_vpc.vpc_id
  vpc_cidr          = module.pre_prod_vpc.vpc_cidr
  private_subnet_ids = module.pre_prod_vpc.private_subnet_ids
  kubernetes_version = "1.28"
  
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

module "stage_eks" {
  source            = "./modules/eks"
  providers         = { aws = aws.eu-west-1 }
  environment       = "stage"
  vpc_id            = module.stage_vpc.vpc_id
  vpc_cidr          = module.stage_vpc.vpc_cidr
  private_subnet_ids = module.stage_vpc.private_subnet_ids
  kubernetes_version = "1.28"
  
  node_groups = {
    app = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      max_size       = 4
      min_size       = 1
      labels = {
        "role" = "app"
      }
    }
    monitoring = {
      instance_types = ["t3.medium"]
      desired_size   = 1
      max_size       = 2
      min_size       = 1
      labels = {
        "role" = "monitoring"
      }
    }
  }
}

module "dev_eks" {
  source            = "./modules/eks"
  providers         = { aws = aws.ap-south-1 }
  environment       = "dev"
  vpc_id            = module.dev_vpc.vpc_id
  vpc_cidr          = module.dev_vpc.vpc_cidr
  private_subnet_ids = module.dev_vpc.private_subnet_ids
  kubernetes_version = "1.28"
  
  node_groups = {
    app = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      labels = {
        "role" = "app"
      }
    }
    monitoring = {
      instance_types = ["t3.medium"]
      desired_size   = 1
      max_size       = 2
      min_size       = 1
      labels = {
        "role" = "monitoring"
      }
    }
  }
}

module "shared_services_eks" {
  source            = "./modules/eks"
  providers         = { aws = aws.us-east-1 }
  environment       = "shared-services"
  vpc_id            = module.shared_services_vpc.vpc_id
  vpc_cidr          = module.shared_services_vpc.vpc_cidr
  private_subnet_ids = module.shared_services_vpc.private_subnet_ids
  kubernetes_version = "1.28"
  
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