output "service_uri" {
  description = "Cloud Run URI. Callers still need roles/run.invoker."
  value       = module.cloud_run.uri
}

output "service_account_email" {
  description = "Runtime service account email."
  value       = module.cloud_run.service_account_email
}

output "sql_connection_name" {
  description = "Cloud SQL connection name."
  value       = module.cloud_sql.connection_name
}

output "sql_private_ip" {
  description = "Cloud SQL private IP."
  value       = module.cloud_sql.private_ip
}

output "secret_id" {
  description = "Secret Manager ID for the database URL."
  value       = module.secret_manager.secret_id
}
