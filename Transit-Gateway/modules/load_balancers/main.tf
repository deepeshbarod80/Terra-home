resource "aws_lb" "alb" {
  name               = "${var.environment}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.internal ? var.private_subnet_ids : var.public_subnet_ids
  
  enable_deletion_protection = var.environment == "prod"
  
  access_logs {
    bucket  = aws_s3_bucket.logs.id
    prefix  = "alb-logs"
    enabled = true
  }
  
  tags = {
    Name        = "${var.environment}-alb"
    Environment = var.environment
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.internal ? [var.vpc_cidr] : ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.internal ? [var.vpc_cidr] : ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.environment}-alb-logs-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name        = "${var.environment}-alb-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  
  rule {
    id     = "log-expiration"
    status = "Enabled"
    
    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
      }
      Action   = "s3:PutObject"
      Resource = "${aws_s3_bucket.logs.arn}/alb-logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    }]
  })
}

# WAF association if available
resource "aws_wafv2_web_acl_association" "alb" {
  count        = var.waf_web_acl_arn != "" ? 1 : 0
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = var.waf_web_acl_arn
}

# Default listener for HTTPS
resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn
  
  default_action {
    type = "fixed-response"
    
    fixed_response {
      content_type = "text/plain"
      message_body = "No routes configured"
      status_code  = "404"
    }
  }
}

# Default listener for HTTP (redirects to HTTPS if certificate is provided)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type = var.certificate_arn != "" ? "redirect" : "fixed-response"
    
    dynamic "redirect" {
      for_each = var.certificate_arn != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    
    dynamic "fixed_response" {
      for_each = var.certificate_arn == "" ? [1] : []
      content {
        content_type = "text/plain"
        message_body = "No routes configured"
        status_code  = "404"
      }
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}