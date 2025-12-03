output "secret_arn" {
  description = "ARN of the created secret"
  value       = aws_secretsmanager_secret.example.arn
}

output "secret_value" {
  description = "Secret value (sensitive)"
  value       = jsondecode(data.aws_secretsmanager_secret_version.example.secret_string)
  sensitive   = true
}