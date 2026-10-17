output "secret_arn" {
  description = "ARN of the application database URL secret. The secret value is not managed here."
  value       = aws_secretsmanager_secret.database_url.arn
}

output "secret_name" {
  description = "Name of the application database URL secret."
  value       = aws_secretsmanager_secret.database_url.name
}

output "kms_key_arn" {
  description = "ARN of the CMK that encrypts the application secret."
  value       = aws_kms_key.secrets.arn
}
