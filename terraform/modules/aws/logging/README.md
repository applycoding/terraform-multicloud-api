# AWS logging module

CloudWatch log group for the API containers.

The group is encrypted with a customer managed key and retains events for 365 days. The ECS execution role needs `kms:GenerateDataKey` and `kms:Decrypt` on `kms_key_arn`; the AWS stack grants that.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | string |  | Prefix for the KMS alias. |
| `log_group_name` | string |  | Log group name, starting with `/`. |
| `tags` | map(string) | `{}` | Extra tags. |

## Outputs

| Name | Description |
| --- | --- |
| `log_group_name` | Log group name. |
| `log_group_arn` | Log group ARN. |
| `kms_key_arn` | CMK ARN. |
