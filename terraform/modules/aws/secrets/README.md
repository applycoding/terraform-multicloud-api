# AWS Secrets Manager module

Creates an encrypted secret shell for `PORTFOLIO_DATABASE_URL` and a 30 day rotation schedule.

This module does not write a secret version. Put the initial value with `aws secretsmanager put-secret-value` before rotation can succeed, and supply your own rotation Lambda. The RDS master password is a different secret, created by the RDS module with `manage_master_user_password`.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | string |  | Prefix for the KMS alias. |
| `secret_name` | string |  | Secret name. |
| `rotation_lambda_arn` | string |  | Rotation function ARN in your account. |
| `tags` | map(string) | `{}` | Extra tags. |

## Outputs

| Name | Description |
| --- | --- |
| `secret_arn` | Secret ARN. |
| `secret_name` | Secret name. |
| `kms_key_arn` | CMK ARN. |
