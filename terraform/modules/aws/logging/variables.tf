variable "name" {
  description = "Short lowercase prefix used for the KMS alias."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name))
    error_message = "name must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "log_group_name" {
  description = "CloudWatch log group name. Must start with a slash, for example /portfolio-dev/api."
  type        = string

  validation {
    condition     = startswith(var.log_group_name, "/")
    error_message = "log_group_name must start with /."
  }
}

variable "tags" {
  description = "Extra tags applied to taggable resources."
  type        = map(string)
  default     = {}
}
