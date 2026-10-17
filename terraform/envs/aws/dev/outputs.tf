output "alb_dns_name" {
  description = "Public DNS name of the load balancer."
  value       = module.platform.alb_dns_name
}

output "cluster_name" {
  description = "ECS cluster name."
  value       = module.platform.cluster_name
}

output "service_name" {
  description = "ECS service name."
  value       = module.platform.service_name
}

output "rds_endpoint" {
  description = "Postgres hostname."
  value       = module.platform.rds_endpoint
}

output "database_secret_arn" {
  description = "Application database URL secret ARN."
  value       = module.platform.database_secret_arn
}

output "master_user_secret_arn" {
  description = "RDS-managed master password secret ARN."
  value       = module.platform.master_user_secret_arn
}

output "log_group_name" {
  description = "Application log group name."
  value       = module.platform.log_group_name
}
