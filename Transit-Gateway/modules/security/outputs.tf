output "kms_key_arn" {
  value = aws_kms_key.main.arn
}

output "flow_logs_role_arn" {
  value = aws_iam_role.flow_logs.arn
}

output "flow_logs_destination" {
  value = aws_cloudwatch_log_group.flow_logs.arn
}

output "waf_web_acl_arn" {
  value = aws_wafv2_web_acl.main.arn
}