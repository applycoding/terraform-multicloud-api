# GCP stack

Wires the network, Cloud SQL, Secret Manager, and Cloud Run modules, then grants the Cloud Run service account an IAM database user.

Environment roots in `terraform/envs/gcp` enable the required APIs and call this stack.

## Inputs

See `variables.tf`. Every variable has a description.

## Outputs

| Name | Description |
| --- | --- |
| `service_uri` | Cloud Run URI. |
| `service_account_email` | Runtime service account. |
| `sql_connection_name` | Cloud SQL connection name. |
| `sql_private_ip` | Cloud SQL private IP. |
| `secret_id` | Database URL secret ID. |
