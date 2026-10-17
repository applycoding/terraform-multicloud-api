output "service_uri" {
  description = "Cloud Run URI. Callers still need roles/run.invoker."
  value       = module.platform.service_uri
}

output "service_account_email" {
  description = "Runtime service account email."
  value       = module.platform.service_account_email
}

output "sql_connection_name" {
  description = "Cloud SQL connection name."
  value       = module.platform.sql_connection_name
}

output "sql_private_ip" {
  description = "Cloud SQL private IP."
  value       = module.platform.sql_private_ip
}

output "secret_id" {
  description = "Secret Manager ID for the database URL."
  value       = module.platform.secret_id
}
