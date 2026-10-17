# GCP dev

Thin root for the dev stack. It enables the APIs the modules need, then calls the GCP stack.

Copy `terraform.tfvars.example` to `terraform.tfvars` and replace the project ID and image.

```bash
terraform init -backend-config=../../../backends/gcp-dev.hcl
```

CI validates this root with `-backend=false`.

Cloud SQL and Cloud Run deletion protection are hardcoded. Turn those booleans off in the modules before a destroy. This directory has not been applied.
