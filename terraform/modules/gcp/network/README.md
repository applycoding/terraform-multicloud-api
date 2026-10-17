# GCP network module

Custom VPC for Cloud Run direct VPC egress and private Cloud SQL.

- Subnet flow logs and Private Google Access are on.
- A `/16` is reserved for service networking. Cloud SQL gets a private IP from that range.
- Ingress allows TCP 5432 from the application subnet and denies other ingress.
- Enable `compute.googleapis.com` and `servicenetworking.googleapis.com` before apply. The environment root does that.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | string |  | Name prefix. |
| `project_id` | string |  | Project ID. |
| `region` | string |  | Subnet region. |
| `subnet_cidr` | string |  | Application subnet CIDR. |
| `private_service_address` | string | `10.80.0.0` | Start of the private services `/16`. |

## Outputs

| Name | Description |
| --- | --- |
| `network_id` | Network ID. |
| `network_name` | Network name. |
| `network_self_link` | Network self link. |
| `subnet_id` | Subnet ID. |
| `subnet_self_link` | Subnet self link. |
| `private_service_connection` | Service networking connection ID. |
