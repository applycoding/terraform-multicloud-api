variable "name" {
  description = "Short lowercase prefix for the service and its service account."
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
  description = "Cloud Run region."
  type        = string
}

variable "environment" {
  description = "Value published as PORTFOLIO_ENVIRONMENT."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "image" {
  description = "Container image with a version tag or digest. The latest tag is rejected."
  type        = string

  validation {
    condition     = length(var.image) > 0 && !endswith(var.image, ":latest")
    error_message = "image must be set and must not use the latest tag."
  }
}

variable "network_self_link" {
  description = "VPC self link for direct VPC egress."
  type        = string
}

variable "subnet_self_link" {
  description = "Subnet self link for direct VPC egress."
  type        = string
}

variable "database_secret_id" {
  description = "Secret Manager secret ID injected as PORTFOLIO_DATABASE_URL."
  type        = string
}

variable "min_instance_count" {
  description = "Minimum Cloud Run instances. Zero scales to nothing when idle."
  type        = number
  default     = 0

  validation {
    condition     = var.min_instance_count >= 0 && var.min_instance_count <= 2
    error_message = "min_instance_count must be 0, 1, or 2."
  }
}

variable "max_instance_count" {
  description = "Maximum Cloud Run instances."
  type        = number
  default     = 2

  validation {
    condition     = var.max_instance_count >= var.min_instance_count && var.max_instance_count <= 10
    error_message = "max_instance_count must be between min_instance_count and 10."
  }
}

variable "invoker_members" {
  description = "IAM members granted roles/run.invoker. allUsers and allAuthenticatedUsers are rejected."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for member in var.invoker_members :
      member != "allUsers" && member != "allAuthenticatedUsers"
    ])
    error_message = "Public invoker members are not allowed."
  }
}

variable "labels" {
  description = "Labels applied to the service."
  type        = map(string)
  default     = {}
}
