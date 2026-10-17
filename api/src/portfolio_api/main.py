"""HTTP API for the multicloud portfolio demo.

The process starts without a database. Connection settings are optional so
the container and the unit tests run with no cloud account.
"""

from collections.abc import Mapping

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from pydantic_settings import BaseSettings, SettingsConfigDict

from portfolio_api import __version__


class Settings(BaseSettings):
    """Runtime settings loaded from PORTFOLIO_* environment variables."""

    model_config = SettingsConfigDict(env_prefix="PORTFOLIO_", extra="ignore")

    app_name: str = "portfolio-api"
    environment: str = "local"
    version: str = __version__
    database_url: str | None = None


class HealthResponse(BaseModel):
    status: str


class ReadinessResponse(BaseModel):
    status: str
    database_configured: bool


class InfoResponse(BaseModel):
    name: str
    environment: str
    version: str
    demo: bool = True


class Project(BaseModel):
    slug: str
    title: str
    summary: str
    cloud: str


settings = Settings()

PROJECTS: Mapping[str, Project] = {
    "multicloud-api": Project(
        slug="multicloud-api",
        title="Multicloud API platform",
        summary="Sample catalog entry for a containerized API with ECS Fargate and Cloud Run Terraform.",
        cloud="aws-gcp",
    ),
    "private-postgres": Project(
        slug="private-postgres",
        title="Private Postgres",
        summary="Sample catalog entry for a database kept off the public internet, with IAM auth and managed secrets.",
        cloud="aws-gcp",
    ),
}

app = FastAPI(
    title=settings.app_name,
    version=settings.version,
    summary="Demo API used by the multicloud Terraform portfolio.",
)


def _info() -> InfoResponse:
    return InfoResponse(
        name=settings.app_name,
        environment=settings.environment,
        version=settings.version,
    )


@app.get("/", response_model=InfoResponse)
def root() -> InfoResponse:
    return _info()


@app.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    return HealthResponse(status="ok")


@app.get("/ready", response_model=ReadinessResponse)
def ready() -> ReadinessResponse:
    return ReadinessResponse(
        status="ok",
        database_configured=bool(settings.database_url),
    )


@app.get("/v1/info", response_model=InfoResponse)
def info() -> InfoResponse:
    return _info()


@app.get("/v1/projects", response_model=list[Project])
def list_projects() -> list[Project]:
    return list(PROJECTS.values())


@app.get("/v1/projects/{slug}", response_model=Project)
def get_project(slug: str) -> Project:
    project = PROJECTS.get(slug)
    if project is None:
        raise HTTPException(status_code=404, detail="Project not found.")
    return project
