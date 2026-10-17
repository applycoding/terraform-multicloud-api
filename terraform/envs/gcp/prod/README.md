# GCP prod

Same root module as dev, with a separate state prefix. The example keeps one warm Cloud Run instance and a larger Cloud SQL tier.

```bash
terraform init -backend-config=../../../backends/gcp-prod.hcl
```

Copy `terraform.tfvars.example` and replace the project ID and image. This directory has not been applied.
