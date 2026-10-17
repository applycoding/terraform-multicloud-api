# AWS dev

Thin root for the dev stack. Copy `terraform.tfvars.example` to `terraform.tfvars` and replace the placeholder account, certificate, image, rotation function, and bucket names.

Remote state is partial. Pass a backend file at init:

```bash
terraform init -backend-config=../../../backends/aws-dev.hcl
```

`terraform validate` in CI uses `-backend=false` and does not read that file.

Deletion protection is hardcoded on the load balancer and the database. Empty the log buckets or rely on `force_destroy`, then set deletion protection to false in the modules before a destroy. This directory has not been applied.
