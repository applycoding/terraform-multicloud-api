# AWS stack

Wires the VPC, logging, Secrets Manager, ALB, ECS, and RDS modules into one platform.

Environment roots in `terraform/envs/aws` call this stack. They differ by variables, not by a second copy of the resources.

## Inputs

See `variables.tf`. Every variable has a description. Sizing inputs (`desired_count`, `task_cpu`, `task_memory`, `database_instance_class`, `single_nat_gateway`) are the ones an environment should change.

## Outputs

| Name | Description |
| --- | --- |
| `alb_dns_name` | Load balancer DNS name. |
| `cluster_name` | ECS cluster. |
| `service_name` | ECS service. |
| `rds_endpoint` | Postgres hostname. |
| `database_secret_arn` | Application secret ARN. |
| `master_user_secret_arn` | RDS master secret ARN. |
| `log_group_name` | Application log group. |
