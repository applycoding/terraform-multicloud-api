output "log_group_name" {
  description = "Name of the application log group."
  value       = aws_cloudwatch_log_group.api.name
}

output "log_group_arn" {
  description = "ARN of the application log group."
  value       = aws_cloudwatch_log_group.api.arn
}

output "kms_key_arn" {
  description = "ARN of the CMK that encrypts the application log group."
  value       = aws_kms_key.logs.arn
}
