variable "name" {
  description = "Short lowercase prefix. The instance name is this prefix plus -pg."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name))
    error_message = "name must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for the instance and the CMEK."
  type        = string
}

variable "network_id" {
  description = "VPC network ID used for the private IP."
  type        = string
}

variable "private_service_connection" {
  description = "Service networking connection ID. The instance waits for this value and checks that it is non-empty."
  type        = string
}

variable "tier" {
  description = "Cloud SQL machine tier. Shared-core and custom tiers require the Enterprise edition, which this module sets."
  type        = string
  default     = "db-custom-1-3840"
}

variable "database_name" {
  description = "Application database name."
  type        = string
  default     = "portfolio"

  validation {
    condition     = can(regex("^[a-z][a-z0-9_]{0,30}$", var.database_name))
    error_message = "database_name must be a lowercase identifier."
  }
}

variable "labels" {
  description = "Labels applied to the instance."
  type        = map(string)
  default     = {}
}
