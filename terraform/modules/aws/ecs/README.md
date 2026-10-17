# AWS ECS module

Fargate service for the demo API.

- Tasks run in private subnets with `assign_public_ip = false` and platform version `LATEST`.
- The task role and the execution role are different. The task role has no AWS permissions because the sample process does not call AWS APIs.
- The execution role can pull the image, write logs, read one secret, and use the two CMKs that protect logs and that secret.
- The container runs as uid 1000, is not privileged, and has a read-only root filesystem.
- `PORTFOLIO_DATABASE_URL` comes from Secrets Manager. It is not an environment literal.
- Container Insights and the deployment circuit breaker are enabled.

The module also adds an egress rule on the load balancer security group toward the tasks.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | string |  | Name prefix. |
| `environment` | string |  | `dev` or `prod`. |
| `vpc_id` | string |  | VPC ID. |
| `vpc_cidr` | string |  | VPC CIDR for DNS and Postgres egress. |
| `private_subnet_ids` | list(string) |  | Private subnets. |
| `alb_security_group_id` | string |  | Load balancer security group. |
| `target_group_arn` | string |  | Target group ARN. |
| `container_image` | string |  | Pinned image URI. |
| `container_port` | number | `8080` | Container port. |
| `desired_count` | number | `1` | Task count, 1 to 4. |
| `cpu` | number | `256` | Fargate CPU units. |
| `memory` | number | `512` | Fargate memory in MiB. |
| `log_group_name` | string |  | Log group name. |
| `log_kms_key_arn` | string |  | Log CMK ARN. |
| `database_secret_arn` | string |  | Database URL secret ARN. |
| `secrets_kms_key_arn` | string |  | Secret CMK ARN. |
| `tags` | map(string) | `{}` | Extra tags. |

## Outputs

| Name | Description |
| --- | --- |
| `cluster_name` | Cluster name. |
| `service_name` | Service name. |
| `security_group_id` | Task security group ID. |
| `task_definition_arn` | Task definition ARN. |
