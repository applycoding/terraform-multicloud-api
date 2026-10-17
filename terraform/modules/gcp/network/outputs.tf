output "network_id" {
  description = "VPC network ID."
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "VPC network name."
  value       = google_compute_network.this.name
}

output "network_self_link" {
  description = "VPC network self link."
  value       = google_compute_network.this.self_link
}

output "subnet_id" {
  description = "Application subnet ID."
  value       = google_compute_subnetwork.app.id
}

output "subnet_self_link" {
  description = "Application subnet self link."
  value       = google_compute_subnetwork.app.self_link
}

output "private_service_connection" {
  description = "ID of the service networking connection. Cloud SQL waits on this output."
  value       = google_service_networking_connection.private.id
}
