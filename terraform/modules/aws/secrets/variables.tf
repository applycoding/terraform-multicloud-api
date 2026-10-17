variable "name" {
  description = "Short lowercase prefix used for the KMS alias."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name))
    error_message = "name must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "secret_name" {
  description = "Secrets Manager name for the application database URL."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9/_+=.@-]{1,200}$", var.secret_name))
    error_message = "secret_name contains unsupported characters."
  }
}

variable "rotation_lambda_arn" {
  description = "ARN of a Secrets Manager rotation function in your account. This module does not create the function."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:lambda:[a-z0-9-]+:[0-9]{12}:function:.+", var.rotation_lambda_arn))
    error_message = "rotation_lambda_arn must be a Lambda function ARN."
  }
}

variable "tags" {
  description = "Extra tags applied to taggable resources."
  type        = map(string)
  default     = {}
}
