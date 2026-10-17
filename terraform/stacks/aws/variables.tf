variable "name" {
  description = "Short lowercase prefix shared by the AWS modules."
  type        = string
}

variable "environment" {
  description = "Deployment environment, dev or prod."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the application VPC."
  type        = string
}

variable "availability_zones" {
  description = "Pinned availability zone names for the VPC."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for all private subnets."
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the public HTTPS listener."
  type        = string
}

variable "container_image" {
  description = "Pinned API image URI."
  type        = string
}

variable "desired_count" {
  description = "Number of Fargate tasks."
  type        = number
  default     = 1
}

variable "task_cpu" {
  description = "Fargate CPU units."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate memory in MiB."
  type        = number
  default     = 512
}

variable "database_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "rotation_lambda_arn" {
  description = "Secrets Manager rotation Lambda ARN."
  type        = string
}

variable "alb_logs_bucket_name" {
  description = "Globally unique ALB access log bucket name."
  type        = string
}

variable "alb_logs_access_bucket_name" {
  description = "Globally unique bucket for S3 server access logs of the ALB log bucket."
  type        = string
}

variable "tags" {
  description = "Extra tags passed to every module."
  type        = map(string)
  default     = {}
}
