# AWS VPC module

Application VPC for the portfolio demo.

- DNS hostnames enabled.
- Public subnets for the load balancer. Instances do not receive public IPs automatically.
- Private subnets for Fargate tasks and Postgres.
- One NAT gateway by default (`single_nat_gateway = true`). Set it false for one NAT gateway per AZ.
- The default security group is present and has no rules.
- VPC flow logs ship to CloudWatch with a customer managed key and 365 days of retention.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | string |  | Lowercase prefix. |
| `cidr_block` | string |  | VPC CIDR. |
| `az_count` | number | `2` | Availability zones, 2 or 3. |
| `single_nat_gateway` | bool | `true` | Share one NAT gateway. |
| `tags` | map(string) | `{}` | Extra tags. |

## Outputs

| Name | Description |
| --- | --- |
| `vpc_id` | VPC ID. |
| `vpc_cidr` | VPC CIDR. |
| `public_subnet_ids` | Public subnet IDs. |
| `private_subnet_ids` | Private subnet IDs. |
