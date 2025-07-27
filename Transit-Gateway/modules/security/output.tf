output "waf_arn" {
  value = aws_wafv2_web_acl.main.arn
}
output "kms_key_id" {
  value = aws_kms_key.main.id
}