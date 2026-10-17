variable "environment" {
  description = "Environment name. Set dev in this directory and prod in the prod directory."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "region" {
  description = "AWS region for this environment."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR for the application VPC."
  type        = string
}

variable "az_count" {
  description = "Number of availability zones."
  type        = number
  default     = 2
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for all private subnets."
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ACM certificate ARN in this region."
  type        = string
}

variable "container_image" {
  description = "Pinned API image URI in ECR or another registry the task can pull."
  type        = string
}

variable "desired_count" {
  description = "Number of Fargate tasks."
  type        = number
}

variable "task_cpu" {
  description = "Fargate CPU units."
  type        = number
}

variable "task_memory" {
  description = "Fargate memory in MiB."
  type        = number
}

variable "database_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "rotation_lambda_arn" {
  description = "Secrets Manager rotation Lambda ARN in this account."
  type        = string
}

variable "alb_logs_bucket_name" {
  description = "Globally unique ALB access log bucket name."
  type        = string
}

variable "alb_logs_access_bucket_name" {
  description = "Globally unique bucket for S3 access logs of the ALB log bucket."
  type        = string
}
