output "secret_id" {
  description = "Secret identifier used by Cloud Run."
  value       = google_secret_manager_secret.app.secret_id
}

output "secret_name" {
  description = "Full resource name of the secret."
  value       = google_secret_manager_secret.app.name
}
