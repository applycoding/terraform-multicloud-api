# AWS prod

Same root module as dev, with a separate state key and larger example settings: two tasks, a NAT gateway per AZ, and a larger database class.

```bash
terraform init -backend-config=../../../backends/aws-prod.hcl
```

Copy `terraform.tfvars.example` and replace every placeholder. This directory has not been applied.
