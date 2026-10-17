resource "google_compute_network" "this" {
  project                 = var.project_id
  name                    = var.name
  auto_create_subnetworks = false
  description             = "VPC for the portfolio API demo."
}

resource "google_compute_subnetwork" "app" {
  project                    = var.project_id
  name                       = "${var.name}-app"
  region                     = var.region
  network                    = google_compute_network.this.id
  ip_cidr_range              = var.subnet_cidr
  private_ip_google_access   = true
  private_ipv6_google_access = "ENABLE_OUTBOUND_VM_ACCESS_TO_GOOGLE"
  description                = "Subnet for Cloud Run direct VPC egress."

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_global_address" "private_service" {
  project       = var.project_id
  name          = "${var.name}-google-services"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  address       = var.private_service_address
  network       = google_compute_network.this.id
}

resource "google_service_networking_connection" "private" {
  network                 = google_compute_network.this.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service.name]
}

resource "google_compute_firewall" "postgres" {
  project     = var.project_id
  name        = "${var.name}-postgres"
  network     = google_compute_network.this.name
  description = "Postgres from the application subnet only."
  direction   = "INGRESS"
  priority    = 1000

  source_ranges = [var.subnet_cidr]

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "deny_ingress" {
  project     = var.project_id
  name        = "${var.name}-deny-ingress"
  network     = google_compute_network.this.name
  description = "Explicit deny for other ingress."
  direction   = "INGRESS"
  priority    = 65534

  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
