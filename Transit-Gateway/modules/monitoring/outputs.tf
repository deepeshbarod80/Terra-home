output "cloudwatch_dashboard_name" {
  value = aws_cloudwatch_dashboard.main.dashboard_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "monitoring_security_group_id" {
  value = aws_security_group.monitoring.id
}