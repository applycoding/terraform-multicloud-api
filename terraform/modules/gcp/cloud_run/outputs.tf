output "service_name" {
  description = "Cloud Run service name."
  value       = google_cloud_run_v2_service.api.name
}

output "uri" {
  description = "Cloud Run service URI."
  value       = google_cloud_run_v2_service.api.uri
}

output "service_account_email" {
  description = "Runtime service account email."
  value       = google_service_account.run.email
}
