# path: Makefile
.PHONY: help install format lint type-check test test-light test-heavy coverage clean \
        docker-build docker-up docker-down migrate migrate-create security-scan \
        ci-local sla-check logs monitoring

# Variables
PYTHON := python3.12
POETRY := poetry
DOCKER_COMPOSE := docker-compose
APP_NAME := hotel-ai-reception
DOCKER_REGISTRY := ghcr.io
DOCKER_ORG := your-org
VERSION := $(shell git describe --tags --always --dirty)

# Default target
help:
	@echo "Available commands:"
	@echo "  make install        - Install dependencies"
	@echo "  make format         - Format code with black and isort"
	@echo "  make lint           - Run ruff linter"
	@echo "  make type-check     - Run mypy type checker"
	@echo "  make test           - Run all tests"
	@echo "  make test-light     - Run light tests only"
	@echo "  make test-heavy     - Run heavy tests only"
	@echo "  make coverage       - Generate test coverage report"
	@echo "  make security-scan  - Run security scans"
	@echo "  make docker-build   - Build Docker images"
	@echo "  make docker-up      - Start all services"
	@echo "  make docker-down    - Stop all services"
	@echo "  make migrate        - Run database migrations"
	@echo "  make ci-local       - Run full CI pipeline locally"
	@echo "  make sla-check      - Run SLA performance check"

# Installation
install:
	$(POETRY) install --with dev

# Code formatting
format:
	$(POETRY) run black backend tests
	$(POETRY) run isort backend tests
	$(POETRY) run ruff check --fix backend tests

fmt: format

# Linting
lint:
	$(POETRY) run ruff check backend tests
	$(POETRY) run black --check backend tests
	$(POETRY) run isort --check-only backend tests

# Type checking
type-check:
	$(POETRY) run mypy backend

# Testing
test:
	$(POETRY) run pytest -v

test-light:
	$(POETRY) run pytest -v -m light

test-heavy:
	$(POETRY) run pytest -v -m heavy

coverage:
	$(POETRY) run pytest --cov=backend --cov-report=html --cov-report=term-missing
	@echo "Coverage report generated in htmlcov/index.html"

# Security scanning
security-scan:
	$(POETRY) run bandit -r backend -f json -o bandit-report.json
	$(POETRY) run safety check --json --output safety-report.json
	docker run --rm -v "$$(pwd)":/src aquasec/trivy fs /src --severity HIGH,CRITICAL

# Database migrations
migrate:
	$(POETRY) run alembic upgrade head

migrate-create:
	@read -p "Enter migration message: " msg; \
	$(POETRY) run alembic revision --autogenerate -m "$$msg"

migrate-down:
	$(POETRY) run alembic downgrade -1

migrate-history:
	$(POETRY) run alembic history

# Docker commands
docker-build:
	$(DOCKER_COMPOSE) build

docker-up:
	$(DOCKER_COMPOSE) up -d
	@echo "Waiting for services to be healthy..."
	@sleep 10
	@$(DOCKER_COMPOSE) ps

docker-down:
	$(DOCKER_COMPOSE) down

docker-logs:
	$(DOCKER_COMPOSE) logs -f app

docker-clean:
	$(DOCKER_COMPOSE) down -v
	docker system prune -f

# CI/CD
ci-local: lint type-check test-light security-scan
	@echo "✓ All CI checks passed!"

ci-heavy: lint type-check test security-scan docker-build
	@echo "✓ All CI checks with heavy tests passed!"

# SLA check
sla-check:
	@echo "Running SLA performance check..."
	$(PYTHON) tools/sla_check.py
	@echo "SLA check complete. Results in report.csv"

# Monitoring
logs:
	$(DOCKER_COMPOSE) logs -f app caddy

monitoring:
	@echo "Opening monitoring dashboards..."
	@echo "Grafana: http://localhost:3000 (admin/$(GRAFANA_ADMIN_PASSWORD))"
	@echo "Prometheus: http://localhost:9090"
	@open http://localhost:3000 || xdg-open http://localhost:3000 || echo "Please open http://localhost:3000"

# Development
dev:
	$(DOCKER_COMPOSE) up -d postgres redis
	$(POETRY) run uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000

shell:
	$(DOCKER_COMPOSE) exec app /bin/bash

db-shell:
	$(DOCKER_COMPOSE) exec postgres psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

redis-cli:
	$(DOCKER_COMPOSE) exec redis redis-cli -a $(REDIS_PASSWORD)

# Clean
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf .coverage htmlcov .pytest_cache .mypy_cache .ruff_cache
	rm -f bandit-report.json safety-report.json report.csv

# Production deployment
deploy:
	@echo "Deploying version $(VERSION)..."
	docker build -t $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(APP_NAME):$(VERSION) -t $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(APP_NAME):latest .
	docker push $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(APP_NAME):$(VERSION)
	docker push $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(APP_NAME):latest

# Pre-commit
pre-commit:
	pre-commit run --all-files

pre-commit-install:
	pre-commit install