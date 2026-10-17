locals {
  services = toset([
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "run.googleapis.com",
    "cloudkms.googleapis.com",
    "pubsub.googleapis.com",
    "iam.googleapis.com",
  ])

  labels = {
    project     = "portfolio-api"
    environment = var.environment
    managed_by  = "terraform"
    demo        = "true"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "required" {
  for_each = local.services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

module "platform" {
  source = "../../../stacks/gcp"

  name                    = "portfolio-${var.environment}"
  project_id              = var.project_id
  region                  = var.region
  environment             = var.environment
  subnet_cidr             = var.subnet_cidr
  private_service_address = var.private_service_address
  image                   = var.image
  database_tier           = var.database_tier
  min_instance_count      = var.min_instance_count
  max_instance_count      = var.max_instance_count
  invoker_members         = var.invoker_members
  labels                  = local.labels

  depends_on = [google_project_service.required]
}
