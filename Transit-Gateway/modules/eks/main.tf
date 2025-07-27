resource "aws_eks_cluster" "main" {
  name     = "${var.environment}-eks"
  role_arn = aws_iam_role.eks.arn
  version  = var.kubernetes_version
  
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }
  
  encryption_config {
    provider {
      key_arn = var.kms_key_arn != "" ? var.kms_key_arn : aws_kms_key.eks[0].arn
    }
    resources = ["secrets"]
  }
  
  enabled_cluster_log_types = [
    "api", 
    "audit", 
    "authenticator", 
    "controllerManager", 
    "scheduler"
  ]
  
  tags = {
    Name        = "${var.environment}-eks"
    Environment = var.environment
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
    aws_cloudwatch_log_group.eks
  ]
}

resource "aws_kms_key" "eks" {
  count                   = var.kms_key_arn == "" ? 1 : 0
  description             = "KMS key for EKS cluster ${var.environment} secrets encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags = {
    Name        = "${var.environment}-eks-kms"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.environment}-eks/cluster"
  retention_in_days = 90
  tags = {
    Name        = "${var.environment}-eks-logs"
    Environment = var.environment
  }
}

resource "aws_security_group" "eks_cluster" {
  name        = "${var.environment}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.environment}-eks-cluster-sg"
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "eks_cluster_ingress" {
  security_group_id = aws_security_group.eks_cluster.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  description       = "Allow API server access from VPC"
}

resource "aws_iam_role" "eks" {
  name = "${var.environment}-eks-cluster-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
  
  tags = {
    Name        = "${var.environment}-eks-cluster-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks.name
}

# Node groups
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.environment}-${each.key}"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids
  
  ami_type       = lookup(each.value, "ami_type", "AL2_x86_64")
  instance_types = lookup(each.value, "instance_types", ["t3.medium"])
  capacity_type  = lookup(each.value, "capacity_type", "ON_DEMAND")
  disk_size      = lookup(each.value, "disk_size", 50)
  
  scaling_config {
    desired_size = lookup(each.value, "desired_size", 2)
    max_size     = lookup(each.value, "max_size", 4)
    min_size     = lookup(each.value, "min_size", 1)
  }
  
  update_config {
    max_unavailable = lookup(each.value, "max_unavailable", 1)
  }
  
  labels = merge(
    {
      "role" = each.key
    },
    lookup(each.value, "labels", {})
  )
  
  tags = {
    Name        = "${var.environment}-${each.key}-node-group"
    Environment = var.environment
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy
  ]
}

resource "aws_iam_role" "node" {
  name = "${var.environment}-eks-node-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  
  tags = {
    Name        = "${var.environment}-eks-node-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

# Fargate profile for serverless workloads
resource "aws_eks_fargate_profile" "main" {
  count                  = var.create_fargate_profile ? 1 : 0
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.environment}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate[0].arn
  subnet_ids             = var.private_subnet_ids
  
  selector {
    namespace = "serverless"
    labels = {
      "fargate" = "true"
    }
  }
  
  tags = {
    Name        = "${var.environment}-fargate-profile"
    Environment = var.environment
  }
}

resource "aws_iam_role" "fargate" {
  count = var.create_fargate_profile ? 1 : 0
  name  = "${var.environment}-eks-fargate-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
  })
  
  tags = {
    Name        = "${var.environment}-eks-fargate-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution" {
  count      = var.create_fargate_profile ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate[0].name
}