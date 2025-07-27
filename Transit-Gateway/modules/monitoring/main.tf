resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EKS", "cluster_failed_node_count", "ClusterName", "${var.environment}-eks"]
          ]
          period = 300
          stat   = "Maximum"
          region = var.region
          title  = "EKS Failed Node Count"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Usage", "ResourceCount", "Type", "Resource", "Resource", "AllocatedIPAddresses", "Service", "VPC", "Class", "None"]
          ]
          period = 300
          stat   = "Maximum"
          region = var.region
          title  = "VPC IP Address Usage"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.environment}/cluster"
  retention_in_days = 90
  kms_key_id        = var.kms_key_arn
  
  tags = {
    Name        = "${var.environment}-eks-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/application/${var.environment}"
  retention_in_days = 90
  kms_key_id        = var.kms_key_arn
  
  tags = {
    Name        = "${var.environment}-application-logs"
    Environment = var.environment
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "eks_node_cpu" {
  alarm_name          = "${var.environment}-eks-node-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors EKS node CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  
  dimensions = {
    ClusterName = "${var.environment}-eks"
  }
}

resource "aws_cloudwatch_metric_alarm" "eks_node_memory" {
  alarm_name          = "${var.environment}-eks-node-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors EKS node memory utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  
  dimensions = {
    ClusterName = "${var.environment}-eks"
  }
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.environment}-monitoring-alerts"
  kms_master_key_id = var.kms_key_arn
  
  tags = {
    Name        = "${var.environment}-monitoring-alerts"
    Environment = var.environment
  }
}

# Security Group for monitoring tools
resource "aws_security_group" "monitoring" {
  name        = "${var.environment}-monitoring-sg"
  description = "Security group for monitoring tools"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Prometheus"
  }
  
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Grafana"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.environment}-monitoring-sg"
    Environment = var.environment
  }
}