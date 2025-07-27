resource "aws_kms_key" "main" {
  description             = "${var.environment} encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  tags = {
    Name        = "${var.environment}-kms-key"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.environment}-key"
  target_key_id = aws_kms_key.main.key_id
}

# IAM role for VPC flow logs
resource "aws_iam_role" "flow_logs" {
  name = "${var.environment}-flow-logs-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
  
  tags = {
    Name        = "${var.environment}-flow-logs-role"
    Environment = var.environment
  }
}

resource "aws_iam_policy" "flow_logs" {
  name        = "${var.environment}-flow-logs-policy"
  description = "Policy for VPC flow logs"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "flow_logs" {
  role       = aws_iam_role.flow_logs.name
  policy_arn = aws_iam_policy.flow_logs.arn
}

# CloudWatch Log Group for VPC flow logs
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc-flow-logs/${var.environment}"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.main.arn
  
  tags = {
    Name        = "${var.environment}-flow-logs"
    Environment = var.environment
  }
}

# Security Group for shared services
resource "aws_security_group" "shared_services" {
  count       = var.environment == "shared-services" ? 1 : 0
  name        = "shared-services-sg"
  description = "Security group for shared services"
  vpc_id      = var.vpc_id
  
  tags = {
    Name        = "shared-services-sg"
    Environment = var.environment
  }
}

# WAF Web ACL for application load balancers
resource "aws_wafv2_web_acl" "main" {
  name        = "${var.environment}-web-acl"
  description = "Web ACL for ${var.environment} environment"
  scope       = "REGIONAL"
  
  default_action {
    allow {}
  }
  
  # AWS Managed Rules
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    
    override_action {
      none {}
    }
    
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
  
  # SQL Injection Protection
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 2
    
    override_action {
      none {}
    }
    
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }
  
  # Rate limiting
  rule {
    name     = "RateLimit"
    priority = 3
    
    action {
      block {}
    }
    
    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }
  }
  
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.environment}-web-acl"
    sampled_requests_enabled   = true
  }
  
  tags = {
    Name        = "${var.environment}-web-acl"
    Environment = var.environment
  }
}