variable "name" {
  description = "Short lowercase prefix. The load balancer name is this prefix plus -alb and must stay within 32 characters."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name))
    error_message = "name must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_id" {
  description = "VPC for the load balancer and target group."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the load balancer. Provide at least two."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "public_subnet_ids must contain at least two subnets."
  }
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener. Create the certificate in your account first."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:acm:[a-z0-9-]+:[0-9]{12}:certificate/.+", var.certificate_arn))
    error_message = "certificate_arn must be an ACM certificate ARN."
  }
}

variable "container_port" {
  description = "Port on the task that the target group uses."
  type        = number
  default     = 8080
}

variable "alb_logs_bucket_name" {
  description = "Globally unique bucket name for ALB access logs."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.alb_logs_bucket_name))
    error_message = "alb_logs_bucket_name must be a valid S3 bucket name."
  }
}

variable "alb_logs_access_bucket_name" {
  description = "Globally unique bucket name that stores server access logs for the ALB log bucket."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.alb_logs_access_bucket_name))
    error_message = "alb_logs_access_bucket_name must be a valid S3 bucket name."
  }
}

variable "tags" {
  description = "Extra tags applied to taggable resources."
  type        = map(string)
  default     = {}
}
