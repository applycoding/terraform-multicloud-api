variable "name" {
  description = "Short lowercase prefix for network resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name))
    error_message = "name must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "project_id" {
  description = "GCP project ID that owns the network."
  type        = string
}

variable "region" {
  description = "Region for the application subnet."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR of the application subnet."
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr must be a valid IPv4 CIDR."
  }
}

variable "private_service_address" {
  description = "Start address of the /16 reserved for private services access. Cloud SQL uses this range."
  type        = string
  default     = "10.80.0.0"
}
