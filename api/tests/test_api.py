"""Unit tests for the demo API. No database or cloud account is required."""

import pytest
from fastapi.testclient import TestClient

from portfolio_api.main import app, settings

client = TestClient(app)


def test_health() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_root_and_info_describe_the_demo() -> None:
    info = client.get("/v1/info")
    root = client.get("/")

    assert info.status_code == 200
    body = info.json()
    assert body["name"] == "portfolio-api"
    assert body["demo"] is True
    assert body["version"]
    assert root.status_code == 200
    assert root.json()["name"] == body["name"]


def test_ready_without_database() -> None:
    response = client.get("/ready")

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "database_configured": False}


def test_ready_reports_configured_database(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "database_url", "postgresql://demo.invalid/portfolio")

    response = client.get("/ready")

    assert response.status_code == 200
    assert response.json()["database_configured"] is True


def test_projects_catalog() -> None:
    listing = client.get("/v1/projects")
    single = client.get("/v1/projects/private-postgres")
    missing = client.get("/v1/projects/not-a-real-project")

    assert listing.status_code == 200
    slugs = {item["slug"] for item in listing.json()}
    assert "multicloud-api" in slugs
    assert single.status_code == 200
    assert single.json()["cloud"] == "aws-gcp"
    assert missing.status_code == 404
