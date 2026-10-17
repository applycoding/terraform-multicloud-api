# AWS RDS module

Private Multi-AZ Postgres 16 for the demo API.

- Storage, backups, the managed master secret, and Performance Insights use a customer managed key.
- `rds.force_ssl=1`.
- IAM database authentication is enabled.
- The master password is created by RDS in Secrets Manager. Terraform never sees it.
- Enhanced monitoring, Postgres logs, 14 day backups, and deletion protection are on.
- The security group accepts TCP 5432 only from the application security group and has no egress rules.

Create a separate least-privilege database user for the application. Point `PORTFOLIO_DATABASE_URL` at that user, not at the master secret.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | string |  | Name prefix. |
| `vpc_id` | string |  | VPC ID. |
| `private_subnet_ids` | list(string) |  | At least two private subnets. |
| `app_security_group_id` | string |  | Task security group allowed to connect. |
| `instance_class` | string | `db.t4g.micro` | Instance class. |
| `database_name` | string | `portfolio` | Database name. |
| `master_username` | string | `portfolio_admin` | Master username. |
| `tags` | map(string) | `{}` | Extra tags. |

## Outputs

| Name | Description |
| --- | --- |
| `endpoint` | Database hostname. |
| `port` | Database port. |
| `database_name` | Database name. |
| `master_user_secret_arn` | RDS-managed master secret ARN. |
| `security_group_id` | Database security group ID. |
