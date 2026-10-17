# AWS ALB module

Public Application Load Balancer for the demo API.

- HTTPS only, TLS 1.3 policy `ELBSecurityPolicy-TLS13-1-2-2021-06`. Port 80 is not open.
- Invalid headers are dropped, deletion protection is on, and desync mitigation is `strictest`.
- Access logs go to a private SSE-S3 bucket. AWS cannot deliver ALB logs to a KMS-encrypted bucket, so that bucket uses SSE-S3 on purpose.
- The log bucket writes server access logs to a second bucket. Both notify an encrypted SQS queue.
- `force_destroy` is true so a sandbox bucket can be removed with its objects. That is a demo convenience.
- The target group is HTTP because TLS stops at the load balancer. Tasks are in private subnets.

The ECS module adds the load balancer's egress rule toward the tasks.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | string |  | Name prefix. |
| `vpc_id` | string |  | VPC ID. |
| `public_subnet_ids` | list(string) |  | At least two public subnets. |
| `certificate_arn` | string |  | ACM certificate ARN. |
| `container_port` | number | `8080` | Target port. |
| `alb_logs_bucket_name` | string |  | ALB log bucket name. |
| `alb_logs_access_bucket_name` | string |  | Bucket access-log destination. |
| `tags` | map(string) | `{}` | Extra tags. |

## Outputs

| Name | Description |
| --- | --- |
| `alb_arn` | Load balancer ARN. |
| `alb_dns_name` | Public DNS name. |
| `alb_zone_id` | Route 53 zone ID. |
| `target_group_arn` | Target group ARN. |
| `security_group_id` | Load balancer security group ID. |
