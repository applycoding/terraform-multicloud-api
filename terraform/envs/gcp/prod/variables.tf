variable "environment" {
  description = "Environment name. Set dev in this directory and prod in the prod directory."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "project_id" {
  description = "GCP project ID for this environment."
  type        = string
}

variable "region" {
  description = "GCP region for Cloud Run, Cloud SQL, and the secret replica."
  type        = string
  default     = "us-central1"
}

variable "subnet_cidr" {
  description = "CIDR of the application subnet."
  type        = string
}

variable "private_service_address" {
  description = "Start address of the private services /16. It must not overlap the subnet."
  type        = string
}

variable "image" {
  description = "Pinned API image URI in Artifact Registry."
  type        = string
}

variable "database_tier" {
  description = "Cloud SQL machine tier."
  type        = string
}

variable "min_instance_count" {
  description = "Minimum Cloud Run instances."
  type        = number
}

variable "max_instance_count" {
  description = "Maximum Cloud Run instances."
  type        = number
}

variable "invoker_members" {
  description = "IAM members allowed to invoke the service. Leave empty until you are ready to call it."
  type        = list(string)
  default     = []
}
