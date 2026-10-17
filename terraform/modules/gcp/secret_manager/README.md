# GCP Secret Manager module

Regional secret for the application database URL.

- The replica uses a customer managed key.
- A Pub/Sub topic receives rotation notifications every 30 days. This module does not add a secret version and does not implement the rotator.
- Add the first version with `gcloud secrets versions add` so the value stays out of Terraform state.

`next_rotation_time` defaults to `2027-01-01T00:00:00Z`. Change it if that timestamp is no longer in the future.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `project_id` | string |  | Project ID. |
| `region` | string |  | Replica and key region. |
| `secret_id` | string |  | Secret ID. |
| `next_rotation_time` | string | `2027-01-01T00:00:00Z` | Next rotation time. |
| `labels` | map(string) | `{}` | Labels. |

## Outputs

| Name | Description |
| --- | --- |
| `secret_id` | Secret ID. |
| `secret_name` | Full secret resource name. |
