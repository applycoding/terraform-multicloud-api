variable "name" {
  description = "Short lowercase prefix shared by the GCP modules."
  type        = string
}

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for Cloud Run, Cloud SQL, and Secret Manager."
  type        = string
}

variable "environment" {
  description = "Deployment environment, dev or prod."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR of the application subnet."
  type        = string
}

variable "private_service_address" {
  description = "Start address of the private services /16."
  type        = string
}

variable "image" {
  description = "Pinned API image URI."
  type        = string
}

variable "database_tier" {
  description = "Cloud SQL machine tier."
  type        = string
  default     = "db-custom-1-3840"
}

variable "min_instance_count" {
  description = "Minimum Cloud Run instances."
  type        = number
  default     = 0
}

variable "max_instance_count" {
  description = "Maximum Cloud Run instances."
  type        = number
  default     = 2
}

variable "invoker_members" {
  description = "IAM members allowed to invoke Cloud Run."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels passed to modules that accept them."
  type        = map(string)
  default     = {}
}
