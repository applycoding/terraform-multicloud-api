variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for the CMEK and the secret replica."
  type        = string
}

variable "secret_id" {
  description = "Secret identifier. Lowercase letters, numbers, and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,50}$", var.secret_id))
    error_message = "secret_id must be a lowercase identifier."
  }
}

variable "next_rotation_time" {
  description = "RFC3339 timestamp for the next rotation notification. It must be in the future when you apply."
  type        = string
  default     = "2027-01-01T00:00:00Z"
}

variable "labels" {
  description = "Labels applied to the secret."
  type        = map(string)
  default     = {}
}
