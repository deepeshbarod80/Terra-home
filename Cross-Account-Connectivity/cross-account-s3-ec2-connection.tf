# Cross-Account S3 and EC2 Connection Script
# This script creates resources to connect S3 buckets and EC2 instances across different AWS accounts and regions

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    # Configure via backend config file or CLI
    # bucket = "your-terraform-state-bucket"
    # key    = "cross-account-connectivity/terraform.tfstate"
    # region = "us-east-1"
    # workspace_key_prefix = "workspaces"
  }
}

# Primary AWS Provider (Account 1)
provider "aws" {
  alias  = "account1"
  region = var.primary_region
  assume_role {
    role_arn = "arn:aws:iam::${var.account1_id}:role/${var.cross_account_role}"
  }
}

# Secondary AWS Provider (Account 2)
provider "aws" {
  alias  = "account2"
  region = var.secondary_region
  assume_role {
    role_arn = "arn:aws:iam::${var.account2_id}:role/${var.cross_account_role}"
  }
}

# Variables
variable "account1_id" {
  description = "AWS Account ID 1"
  type        = string
}

variable "account2_id" {
  description = "AWS Account ID 2"
  type        = string
}

variable "primary_region" {
  description = "Primary AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "cross_account_role" {
  description = "Cross-account role name"
  type        = string
  default     = "CrossAccountAccessRole"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Local values for workspace-aware naming
locals {
  workspace = terraform.workspace
  environment = var.environment != "" ? var.environment : terraform.workspace
  
  common_tags = {
    Environment = local.environment
    Workspace   = local.workspace
    Project     = "cross-account-connectivity"
    ManagedBy   = "terraform"
  }
}

# S3 Bucket in Account 1
resource "aws_s3_bucket" "account1_bucket" {
  provider = aws.account1
  bucket   = "cross-account-bucket-${var.account1_id}-${local.environment}"
  
  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "account1_versioning" {
  provider = aws.account1
  bucket   = aws_s3_bucket.account1_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Policy for Cross-Account Access
resource "aws_s3_bucket_policy" "account1_bucket_policy" {
  provider = aws.account1
  bucket   = aws_s3_bucket.account1_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CrossAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account2_id}:root"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.account1_bucket.arn,
          "${aws_s3_bucket.account1_bucket.arn}/*"
        ]
      }
    ]
  })
}

# VPC and Security Group in Account 1
resource "aws_vpc" "account1_vpc" {
  provider             = aws.account1
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "account1-vpc-${local.environment}"
  })
}

resource "aws_subnet" "account1_subnet" {
  provider                = aws.account1
  vpc_id                  = aws_vpc.account1_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = data.aws_availability_zones.account1_azs.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "account1-subnet-${local.environment}"
  })
}

resource "aws_internet_gateway" "account1_igw" {
  provider = aws.account1
  vpc_id   = aws_vpc.account1_vpc.id

  tags = merge(local.common_tags, {
    Name = "account1-igw-${local.environment}"
  })
}

resource "aws_route_table" "account1_rt" {
  provider = aws.account1
  vpc_id   = aws_vpc.account1_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.account1_igw.id
  }

  tags = merge(local.common_tags, {
    Name = "account1-rt-${local.environment}"
  })
}

resource "aws_route_table_association" "account1_rta" {
  provider       = aws.account1
  subnet_id      = aws_subnet.account1_subnet.id
  route_table_id = aws_route_table.account1_rt.id
}

resource "aws_security_group" "account1_sg" {
  provider = aws.account1
  name     = "account1-sg-${local.environment}"
  vpc_id   = aws_vpc.account1_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "account1-sg-${local.environment}"
  })
}

# IAM Role for EC2 to access S3
resource "aws_iam_role" "ec2_s3_role" {
  provider = aws.account1
  name     = "ec2-s3-cross-account-role-${local.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  provider = aws.account1
  name     = "s3-cross-account-access-${local.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.account1_bucket.arn,
          "${aws_s3_bucket.account1_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_policy_attachment" {
  provider   = aws.account1
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  provider = aws.account1
  name     = "ec2-s3-profile-${local.environment}"
  role     = aws_iam_role.ec2_s3_role.name
}

# EC2 Instance in Account 1
resource "aws_instance" "account1_ec2" {
  provider                    = aws.account1
  ami                         = data.aws_ami.account1_ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.account1_subnet.id
  vpc_security_group_ids      = [aws_security_group.account1_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    bucket_name = aws_s3_bucket.account1_bucket.bucket
  }))

  tags = merge(local.common_tags, {
    Name = "account1-ec2-${local.environment}"
  })
}

# Resources in Account 2
resource "aws_vpc" "account2_vpc" {
  provider             = aws.account2
  cidr_block           = "10.2.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "account2-vpc-${local.environment}"
  })
}

resource "aws_subnet" "account2_subnet" {
  provider                = aws.account2
  vpc_id                  = aws_vpc.account2_vpc.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = data.aws_availability_zones.account2_azs.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "account2-subnet-${local.environment}"
  })
}

resource "aws_internet_gateway" "account2_igw" {
  provider = aws.account2
  vpc_id   = aws_vpc.account2_vpc.id

  tags = merge(local.common_tags, {
    Name = "account2-igw-${local.environment}"
  })
}

resource "aws_route_table" "account2_rt" {
  provider = aws.account2
  vpc_id   = aws_vpc.account2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.account2_igw.id
  }

  tags = merge(local.common_tags, {
    Name = "account2-rt-${local.environment}"
  })
}

resource "aws_route_table_association" "account2_rta" {
  provider       = aws.account2
  subnet_id      = aws_subnet.account2_subnet.id
  route_table_id = aws_route_table.account2_rt.id
}

resource "aws_security_group" "account2_sg" {
  provider = aws.account2
  name     = "account2-sg-${local.environment}"
  vpc_id   = aws_vpc.account2_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "account2-sg-${local.environment}"
  })
}

# IAM Role for Account 2 EC2 to access Account 1 S3
resource "aws_iam_role" "account2_ec2_role" {
  provider = aws.account2
  name     = "ec2-cross-account-s3-role-${local.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "account2_s3_policy" {
  provider = aws.account2
  name     = "cross-account-s3-access-${local.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::cross-account-bucket-${var.account1_id}-${local.environment}",
          "arn:aws:s3:::cross-account-bucket-${var.account1_id}-${local.environment}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "account2_s3_attachment" {
  provider   = aws.account2
  role       = aws_iam_role.account2_ec2_role.name
  policy_arn = aws_iam_policy.account2_s3_policy.arn
}

resource "aws_iam_instance_profile" "account2_profile" {
  provider = aws.account2
  name     = "ec2-cross-account-profile-${local.environment}"
  role     = aws_iam_role.account2_ec2_role.name
}

# EC2 Instance in Account 2
resource "aws_instance" "account2_ec2" {
  provider                    = aws.account2
  ami                         = data.aws_ami.account2_ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.account2_subnet.id
  vpc_security_group_ids      = [aws_security_group.account2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.account2_profile.name
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/user_data_account2.sh", {
    bucket_name = aws_s3_bucket.account1_bucket.bucket
  }))

  tags = merge(local.common_tags, {
    Name = "account2-ec2-${local.environment}"
  })
}

# Data Sources
data "aws_availability_zones" "account1_azs" {
  provider = aws.account1
  state    = "available"
}

data "aws_availability_zones" "account2_azs" {
  provider = aws.account2
  state    = "available"
}

data "aws_ami" "account1_ami" {
  provider    = aws.account1
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "account2_ami" {
  provider    = aws.account2
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Outputs
output "account1_bucket_name" {
  value = aws_s3_bucket.account1_bucket.bucket
}

output "account1_ec2_public_ip" {
  value = aws_instance.account1_ec2.public_ip
}

output "account2_ec2_public_ip" {
  value = aws_instance.account2_ec2.public_ip
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.cross_account_peering.id
}

# VPC Peering Connection
resource "aws_vpc_peering_connection" "cross_account_peering" {
  provider    = aws.account1
  vpc_id      = aws_vpc.account1_vpc.id
  peer_vpc_id = aws_vpc.account2_vpc.id
  peer_region = var.secondary_region
  auto_accept = false

  tags = merge(local.common_tags, {
    Name = "cross-account-peering-${local.environment}"
  })
}

resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  provider                  = aws.account2
  vpc_peering_connection_id = aws_vpc_peering_connection.cross_account_peering.id
  auto_accept               = true

  tags = merge(local.common_tags, {
    Name = "cross-account-peering-accepter-${local.environment}"
  })
}