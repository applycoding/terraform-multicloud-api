# GCP Cloud SQL module

Private Postgres 18 on Cloud SQL Enterprise edition.

- No public IPv4 address.
- Clients must present a trusted client certificate (`ssl_mode = TRUSTED_CLIENT_CERTIFICATE_REQUIRED`). The Cloud SQL Auth Proxy can supply that certificate.
- Regional availability, backups, point-in-time recovery, and a 100 GB autoresize cap.
- CMEK on the data disk. The Cloud SQL service agent receives encrypter/decrypter on that key.
- IAM database authentication is enabled. The stack creates the Cloud Run database user.
- Deletion protection is on in Terraform and in the Cloud SQL API.
- Postgres logging flags follow the usual audit baseline, including pgAudit.

Pass `private_service_connection` from the network module so the instance is not created before peering exists.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | string |  | Name prefix. |
| `project_id` | string |  | Project ID. |
| `region` | string |  | Region. |
| `network_id` | string |  | VPC ID for the private IP. |
| `private_service_connection` | string |  | Service networking connection ID. |
| `tier` | string | `db-custom-1-3840` | Machine tier. |
| `database_name` | string | `portfolio` | Database name. |
| `labels` | map(string) | `{}` | Instance labels. |

## Outputs

| Name | Description |
| --- | --- |
| `instance_name` | Instance name. |
| `connection_name` | Connection name. |
| `private_ip` | Private IP. |
| `database_name` | Database name. |
