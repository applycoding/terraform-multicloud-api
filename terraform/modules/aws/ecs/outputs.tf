output "cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.api.name
}

output "security_group_id" {
  description = "Security group attached to the tasks."
  value       = aws_security_group.tasks.id
}

output "task_definition_arn" {
  description = "ARN of the task definition."
  value       = aws_ecs_task_definition.api.arn
}
