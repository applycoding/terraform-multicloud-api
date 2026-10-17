# GCP Cloud Run module

Cloud Run v2 service for the demo API.

- Direct VPC egress sends private-range traffic, including Cloud SQL, into the VPC. Other traffic stays on the Cloud Run path.
- The runtime service account can read one secret and can log in to Cloud SQL with IAM (`roles/cloudsql.instanceUser`). It does not have a basic role.
- `PORTFOLIO_DATABASE_URL` comes from Secret Manager.
- Invoker IAM stays enabled. `allUsers` is rejected by a variable check.
- Binary Authorization uses the project default policy. Create that policy before apply, or revisions will not start.
- Deletion protection is on.
- CPU is allocated during requests (`cpu_idle = true`) so an idle service with `min_instance_count = 0` does not bill for CPU.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | string |  | Service name prefix. |
| `project_id` | string |  | Project ID. |
| `region` | string |  | Region. |
| `environment` | string |  | `dev` or `prod`. |
| `image` | string |  | Pinned image URI. |
| `network_self_link` | string |  | VPC self link. |
| `subnet_self_link` | string |  | Subnet self link. |
| `database_secret_id` | string |  | Secret ID. |
| `min_instance_count` | number | `0` | Minimum instances. |
| `max_instance_count` | number | `2` | Maximum instances. |
| `invoker_members` | list(string) | `[]` | Members allowed to invoke. |
| `labels` | map(string) | `{}` | Labels. |

## Outputs

| Name | Description |
| --- | --- |
| `service_name` | Service name. |
| `uri` | Service URI. |
| `service_account_email` | Runtime service account email. |
