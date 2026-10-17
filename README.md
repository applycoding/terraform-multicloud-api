# terraform-multicloud-api

Portfolio demonstration by Arpan Bom. A small HTTP API, with Terraform that shows how the same service would be placed on AWS and on GCP.

**This is a demo. Nothing in this repository has been applied to a live AWS or GCP account, and it has not been deployed in production.** CI checks formatting, `terraform validate`, TFLint, Checkov, unit tests, and a Docker build. It does not run `terraform apply` and it does not need cloud credentials.

## Architecture

The API listens on port 8080. `/health` and `/ready` do not open a database connection, so the image runs before a database URL exists. `PORTFOLIO_DATABASE_URL` is injected from a secret when you choose to wire one up.

### AWS

```mermaid
flowchart TB
  client[Client]
  client -->|HTTPS 443| alb[Application Load Balancer]

  subgraph vpc [VPC]
    subgraph publicNets [Public subnets]
      alb
    end
    subgraph privateNets [Private subnets]
      ecs[ECS Fargate tasks]
      rds[(RDS Postgres)]
    end
  end

  alb -->|HTTP inside the VPC| ecs
  ecs -->|TCP 5432| rds
  ecs --> secrets[Secrets Manager]
  ecs --> logs[CloudWatch Logs]
  nat[NAT gateway] --> ecs
  flow[VPC flow logs] --> logs
```

| Piece | Module | What it does |
| --- | --- | --- |
| VPC | `terraform/modules/aws/vpc` | Public and private subnets, NAT, locked default security group, flow logs. |
| Load balancer | `terraform/modules/aws/alb` | HTTPS listener, private log buckets, encrypted event queue. |
| Tasks | `terraform/modules/aws/ecs` | Fargate service, separate execution and task roles, secret injection. |
| Database | `terraform/modules/aws/rds` | Multi-AZ Postgres, encryption, IAM auth, RDS-managed master password. |
| Secret | `terraform/modules/aws/secrets` | CMK-encrypted secret shell and a 30 day rotation schedule. |
| Logs | `terraform/modules/aws/logging` | Application log group, 365 day retention, CMK. |

The dev and prod roots call `terraform/stacks/aws`. They do not copy the resources.

### GCP

```mermaid
flowchart TB
  client[Invoker with roles/run.invoker]
  client --> run[Cloud Run]

  subgraph project [GCP project]
    run -->|private ranges| subnet[VPC subnet]
    subnet --> sql[(Cloud SQL Postgres)]
    run --> secret[Secret Manager]
  end
```

| Piece | Module | What it does |
| --- | --- | --- |
| Network | `terraform/modules/gcp/network` | Custom VPC, flow logs, private services access, limited firewall. |
| Database | `terraform/modules/gcp/cloud_sql` | Private Postgres 18, CMEK, PITR, client certificates required. |
| Secret | `terraform/modules/gcp/secret_manager` | Regional CMEK secret and a rotation notification topic. |
| Service | `terraform/modules/gcp/cloud_run` | Direct VPC egress, dedicated runtime service account, invoker IAM. |

## Repository layout

```text
api/                         FastAPI service, tests, Dockerfile
terraform/modules/aws/       VPC, ALB, ECS, RDS, secrets, logging
terraform/modules/gcp/       network, Cloud SQL, Secret Manager, Cloud Run
terraform/stacks/            one composition per cloud
terraform/envs/aws/{dev,prod}
terraform/envs/gcp/{dev,prod}
terraform/backends/          remote-state examples, not applied
.github/workflows/ci.yml
```

Every module has `variables.tf` and `outputs.tf`. Each variable and output has a description. The module README repeats the inputs and outputs.

## API

```bash
cd api
python -m pip install -r requirements.txt -r requirements-dev.txt
python -m pytest
python -m uvicorn portfolio_api.main:app --app-dir src --host 127.0.0.1 --port 8080
docker build -t portfolio-api:local .
```

Build and push the image yourself before a real `terraform apply`. This repo does not publish an image. Use a version tag or a digest. The Terraform variables reject `:latest`.

## Remote state

Roots use partial backend configuration so `terraform init -backend=false` works in CI.

| Environment | Backend example | State key |
| --- | --- | --- |
| AWS dev | `terraform/backends/aws-dev.hcl.example` | `portfolio/aws/dev/terraform.tfstate` |
| AWS prod | `terraform/backends/aws-prod.hcl.example` | `portfolio/aws/prod/terraform.tfstate` |
| GCP dev | `terraform/backends/gcp-dev.hcl.example` | prefix `portfolio/gcp/dev` |
| GCP prod | `terraform/backends/gcp-prod.hcl.example` | prefix `portfolio/gcp/prod` |

Copy an example to a file you do not commit, fill in the bucket, and init with `-backend-config`. The AWS example expects an encrypted S3 bucket and a DynamoDB lock table. The GCP example expects a GCS bucket. Create those yourself. They are not part of the modules, because the state bucket has to exist before the stack can use it.

Dev and prod are separate directories and separate state keys. They are not Terraform workspaces.

## Apply in a sandbox

These commands are the shape of an apply. They are not a record of one. You need your own AWS or GCP credentials, a state bucket, an ACM certificate or Artifact Registry image, and the willingness to pay for the resources below.

AWS:

```bash
cd terraform/envs/aws/dev
cp terraform.tfvars.example terraform.tfvars
cp ../../../backends/aws-dev.hcl.example backend.hcl
# edit both files
terraform init -backend-config=backend.hcl
terraform plan
```

Before the ECS service can start, push the image and write the database URL:

```bash
aws secretsmanager put-secret-value \
  --secret-id portfolio-dev/database-url \
  --secret-string 'postgresql://app_user:replace-me@db-host:5432/portfolio?sslmode=require'
```

The rotation Lambda referenced by `rotation_lambda_arn` is yours. This repo does not create it. Rotation also needs that initial secret version.

GCP:

```bash
cd terraform/envs/gcp/dev
cp terraform.tfvars.example terraform.tfvars
cp ../../../backends/gcp-dev.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
terraform plan
```

Then add a secret version, and make sure the project has a Binary Authorization policy. Cloud Run is configured with `use_default = true`, so a project with no policy will refuse the revision. Cloud SQL requires a trusted client certificate. The Cloud SQL Auth Proxy can present one. The sample process does not connect by itself.

Invoker IAM stays on. Add a member to `invoker_members` when you want to call the service. `allUsers` is rejected.

### Destroy

Load balancer deletion protection, RDS deletion protection, Cloud SQL deletion protection, and Cloud Run deletion protection are literals in the modules so the security scan can see them. A sandbox destroy needs those set to false, then another apply, then destroy. RDS also keeps a final snapshot. Secrets Manager keeps the application secret for 30 days after delete. KMS keys wait 30 days. S3 log buckets set `force_destroy` so a demo bucket can be removed with its objects.

## Cost notes

Figures are rough public-list illustrations for a small always-on sandbox, not a quote. Prices move, and data transfer is extra. Destroy the stack when you are done looking at it.

### AWS, `us-east-1`, dev-sized example

| Item | Why it shows up | Rough monthly cost |
| --- | --- | --- |
| NAT gateway | One gateway, plus data | about $32 plus $0.045/GB |
| Public IPv4 | NAT address, and the load balancer addresses | about $3.65 each |
| Application Load Balancer | Hours plus LCUs | about $16 to $22 at low traffic |
| Fargate | 0.25 vCPU and 0.5 GB, one task | about $9 |
| RDS Postgres | `db.t4g.micro`, Multi-AZ, 20 GB gp3 | about $25 to $40 |
| KMS | One CMK per concern | about $1 per key |
| Secrets Manager, logs, SQS | Low volume | a few dollars |

The prod example adds a second NAT gateway, a second task, and `db.t4g.small`. Multi-AZ is always on in the module. That is the expensive database choice, and it is deliberate.

### GCP, `us-central1`

| Item | Why it shows up | Rough monthly cost |
| --- | --- | --- |
| Cloud Run | `min_instance_count = 0` in dev | near $0 while idle; request and CPU charges when called |
| Cloud Run prod example | one warm instance | a small always-on charge |
| Cloud SQL | `db-custom-1-3840`, Regional, 20 GB SSD | often $50 to $90 because Regional doubles the instance |
| Secret Manager, Pub/Sub, KMS | Low volume | a few dollars |

Private services access and the subnet do not have a separate hourly fee in this design. Cloud Run uses direct VPC egress, so there is no Serverless VPC Access connector charge.

Zonal Cloud SQL would be cheaper. This demo keeps Regional availability.

## CI

`.github/workflows/ci.yml` runs on pull requests and on pushes to `main`.

- `terraform fmt -check -recursive`
- `terraform init -backend=false` and `terraform validate` in every directory that contains `.tf` files
- `tflint` in each of those directories
- Checkov `3.3.29` on `terraform/`
- pytest
- `docker build`

No cloud credentials are used. `terraform apply` is not a CI step.

### Scanner exceptions

| Check | Where | Why it is skipped |
| --- | --- | --- |
| `CKV_AWS_52` | all S3 versioning | MFA delete cannot be enabled by Terraform. It needs the root user and a hardware MFA device. |
| `CKV_AWS_144` | log buckets | This demo is single-region. Cross-region replication belongs with a second region. |
| `CKV_AWS_145` | log buckets | ALB access logs and S3 server access logs can be written only to SSE-S3 buckets. |
| `CKV_AWS_18` | the access-log bucket | That bucket is the logging destination and does not log to itself. |
| `CKV_AWS_378` | target group | TLS terminates at the load balancer. Tasks speak HTTP on a private subnet. |
| `CKV_AWS_109`, `CKV_AWS_111`, `CKV_AWS_356` | CMK policies and the TLS deny on the log buckets | Key policies need an account-root administration statement, and KMS policies use `Resource *`. The bucket statement is a deny of non-TLS requests. |
| `CKV2_AWS_5` | default security group | The default group is locked and intentionally unused. |

## What you would still do in a real account

- Build the secret rotation function and grant it the CMK and the secret.
- Create an application database user. Do not put the RDS master secret into the task.
- Attach a DNS name to the load balancer or to Cloud Run.
- Add AWS WAF or Cloud Armor if the endpoint is public.
- Turn on cross-region replication for logs if the service runs in more than one region.
