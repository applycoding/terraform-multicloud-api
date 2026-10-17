variable "name" {
  description = "Short lowercase prefix for cluster, service, and role names."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name))
    error_message = "name must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Value published to the container as PORTFOLIO_ENVIRONMENT."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "vpc_id" {
  description = "VPC for the task security group."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR. DNS and Postgres egress from tasks are limited to this block."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the Fargate service."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "private_subnet_ids must contain at least two subnets."
  }
}

variable "alb_security_group_id" {
  description = "Load balancer security group. Tasks accept traffic only from this group, and the module adds the matching egress rule on it."
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN that receives task IP addresses."
  type        = string
}

variable "container_image" {
  description = "Image URI with a version tag or digest. The latest tag is rejected."
  type        = string

  validation {
    condition     = length(var.container_image) > 0 && !endswith(var.container_image, ":latest")
    error_message = "container_image must be set and must not use the latest tag."
  }
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Number of Fargate tasks."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 1 && var.desired_count <= 4
    error_message = "desired_count must be from 1 to 4."
  }
}

variable "cpu" {
  description = "Fargate CPU units for the task."
  type        = number
  default     = 256

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.cpu)
    error_message = "cpu must be a supported Fargate value."
  }
}

variable "memory" {
  description = "Fargate memory in MiB. It must be a legal pair for cpu."
  type        = number
  default     = 512

  validation {
    condition = (
      (var.cpu == 256 && contains([512, 1024, 2048], var.memory)) ||
      (var.cpu == 512 && contains([1024, 2048, 3072, 4096], var.memory)) ||
      (var.cpu == 1024 && var.memory >= 2048 && var.memory <= 8192 && var.memory % 1024 == 0) ||
      (var.cpu == 2048 && var.memory >= 4096 && var.memory <= 16384 && var.memory % 1024 == 0) ||
      (var.cpu == 4096 && var.memory >= 8192 && var.memory <= 30720 && var.memory % 1024 == 0)
    )
    error_message = "memory is not a supported pair for the selected cpu."
  }
}

variable "log_group_name" {
  description = "CloudWatch log group that receives container logs."
  type        = string
}

variable "log_kms_key_arn" {
  description = "CMK used by the log group. The execution role can encrypt log events with it."
  type        = string
}

variable "database_secret_arn" {
  description = "Secret ARN injected as PORTFOLIO_DATABASE_URL."
  type        = string
}

variable "secrets_kms_key_arn" {
  description = "CMK that encrypts the database URL secret."
  type        = string
}

variable "tags" {
  description = "Extra tags applied to taggable resources."
  type        = map(string)
  default     = {}
}
