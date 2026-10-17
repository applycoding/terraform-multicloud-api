output "alb_arn" {
  description = "ARN of the application load balancer."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "Public DNS name of the load balancer."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Route 53 hosted zone ID of the load balancer."
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group the ECS service registers into."
  value       = aws_lb_target_group.api.arn
}

output "security_group_id" {
  description = "Security group attached to the load balancer."
  value       = aws_security_group.alb.id
}
