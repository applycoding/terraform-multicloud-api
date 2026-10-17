# portfolio-api

Small FastAPI service used as the container image in the Terraform examples.

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/health` | Liveness. Always `200` when the process is up. |
| GET | `/ready` | Readiness. Reports whether `PORTFOLIO_DATABASE_URL` is set. It does not open a connection. |
| GET | `/` and `/v1/info` | Service name, environment, and version. |
| GET | `/v1/projects` | Static sample catalog. |
| GET | `/v1/projects/{slug}` | One catalog entry, or `404`. |

The catalog is sample data. It does not describe a live deployment.

## Run locally

```bash
python -m pip install -r requirements.txt -r requirements-dev.txt
python -m pytest
python -m uvicorn portfolio_api.main:app --app-dir src --host 127.0.0.1 --port 8080
```

## Image

```bash
docker build -t portfolio-api:local .
docker run --rm -p 8080:8080 portfolio-api:local
```

The image listens on port `8080` as uid `1000`. Push it to ECR or Artifact Registry yourself before pointing Terraform at it. This repository does not publish an image.
