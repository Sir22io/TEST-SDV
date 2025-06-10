.PHONY: help deploy start stop restart logs clean test lint format docs

# Variables
DOCKER_COMPOSE := docker-compose
PYTHON := python3
PIP := pip3

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

# Default target
help: ## Show this help message
	@echo "CyberToolbox Pro - Make Commands"
	@echo "================================"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Installation and Setup
install: ## Install dependencies
	@echo "$(GREEN)Installing dependencies...$(NC)"
	$(PIP) install -r requirements.txt
	cd src/frontend && npm install

setup-dev: ## Setup development environment
	@echo "$(GREEN)Setting up development environment...$(NC)"
	cp .env.example .env
	$(DOCKER_COMPOSE) build
	$(DOCKER_COMPOSE) up -d db redis
	sleep 10
	$(DOCKER_COMPOSE) exec db createdb -U cybertoolbox cybertoolbox || true
	$(PYTHON) -m alembic upgrade head

# Docker commands
build: ## Build Docker images
	@echo "$(GREEN)Building Docker images...$(NC)"
	$(DOCKER_COMPOSE) build

deploy: ## Deploy the application
	@echo "$(GREEN)Deploying CyberToolbox Pro...$(NC)"
	chmod +x scripts/deploy.sh
	./scripts/deploy.sh

start: ## Start all services
	@echo "$(GREEN)Starting services...$(NC)"
	$(DOCKER_COMPOSE) up -d

stop: ## Stop all services
	@echo "$(YELLOW)Stopping services...$(NC)"
	$(DOCKER_COMPOSE) down

restart: ## Restart all services
	@echo "$(YELLOW)Restarting services...$(NC)"
	$(DOCKER_COMPOSE) restart

logs: ## Show logs
	$(DOCKER_COMPOSE) logs -f

# Database commands
db-migrate: ## Run database migrations
	@echo "$(GREEN)Running database migrations...$(NC)"
	$(DOCKER_COMPOSE) exec app alembic upgrade head

db-rollback: ## Rollback last migration
	@echo "$(YELLOW)Rolling back last migration...$(NC)"
	$(DOCKER_COMPOSE) exec app alembic downgrade -1

db-reset: ## Reset database
	@echo "$(RED)Resetting database...$(NC)"
	$(DOCKER_COMPOSE) down -v
	$(DOCKER_COMPOSE) up -d db
	sleep 10
	$(MAKE) db-migrate

# User management
create-admin: ## Create admin user
	@echo "$(GREEN)Creating admin user...$(NC)"
	$(DOCKER_COMPOSE) exec app python -m app.cli create-admin

# Testing
test: ## Run all tests
	@echo "$(GREEN)Running tests...$(NC)"
	$(DOCKER_COMPOSE) exec app pytest tests/ -v

test-unit: ## Run unit tests only
	@echo "$(GREEN)Running unit tests...$(NC)"
	$(DOCKER_COMPOSE) exec app pytest tests/unit/ -v

test-integration: ## Run integration tests only
	@echo "$(GREEN)Running integration tests...$(NC)"
	$(DOCKER_COMPOSE) exec app pytest tests/integration/ -v

test-coverage: ## Run tests with coverage
	@echo "$(GREEN)Running tests with coverage...$(NC)"
	$(DOCKER_COMPOSE) exec app pytest tests/ --cov=src --cov-report=html --cov-report=term

# Code quality
lint: ## Run linting
	@echo "$(GREEN)Running linting...$(NC)"
	$(DOCKER_COMPOSE) exec app flake8 src/
	$(DOCKER_COMPOSE) exec app black --check src/
	$(DOCKER_COMPOSE) exec app isort --check-only src/

format: ## Format code
	@echo "$(GREEN)Formatting code...$(NC)"
	$(DOCKER_COMPOSE) exec app black src/
	$(DOCKER_COMPOSE) exec app isort src/

security-scan: ## Run security scan
	@echo "$(GREEN)Running security scan...$(NC)"
	$(DOCKER_COMPOSE) exec app bandit -r src/
	$(DOCKER_COMPOSE) exec app safety check

# Documentation
docs: ## Generate documentation
	@echo "$(GREEN)Generating documentation...$(NC)"
	$(DOCKER_COMPOSE) exec app sphinx-build -b html docs/ docs/_build/

docs-serve: ## Serve documentation locally
	@echo "$(GREEN)Serving documentation...$(NC)"
	cd docs/_build && python -m http.server 8080

# Backup and restore
backup: ## Create backup
	@echo "$(GREEN)Creating backup...$(NC)"
	chmod +x scripts/backup.sh
	./scripts/backup.sh

restore: ## Restore from backup
	@echo "$(YELLOW)Restoring from backup...$(NC)"
	chmod +x scripts/restore.sh
	@read -p "Backup name: " backup_name; \
	./scripts/restore.sh $$backup_name

# Monitoring
health-check: ## Check application health
	@echo "$(GREEN)Checking application health...$(NC)"
	curl -f http://localhost:8000/health && echo "$(GREEN)✓ API is healthy$(NC)" || echo "$(RED)✗ API is down$(NC)"
	curl -f http://localhost && echo "$(GREEN)✓ Frontend is healthy$(NC)" || echo "$(RED)✗ Frontend is down$(NC)"

status: ## Show services status
	@echo "$(GREEN)Services status:$(NC)"
	$(DOCKER_COMPOSE) ps

# Maintenance
update: ## Update application
	@echo "$(GREEN)Updating application...$(NC)"
	chmod +x scripts/update.sh
	./scripts/update.sh

clean: ## Clean up containers and volumes
	@echo "$(YELLOW)Cleaning up...$(NC)"
	$(DOCKER_COMPOSE) down -v --remove-orphans
	docker system prune -f

clean-all: ## Clean everything including images
	@echo "$(RED)Cleaning everything...$(NC)"
	$(DOCKER_COMPOSE) down -v --remove-orphans
	docker system prune -af

# Development helpers
shell-app: ## Open shell in app container
	$(DOCKER_COMPOSE) exec app bash

shell-db: ## Open database shell
	$(DOCKER_COMPOSE) exec db psql -U cybertoolbox cybertoolbox

dev-frontend: ## Start frontend development server
	cd src/frontend && npm start

dev-backend: ## Start backend development server
	cd src/backend && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Demo and examples
demo: ## Run demo scan
	@echo "$(GREEN)Running demo scan...$(NC)"
	curl -X POST http://localhost:8000/api/v1/campaigns \
		-H "Content-Type: application/json" \
		-d '{"name": "Demo Scan", "target": "scanme.nmap.org", "tools": ["nmap"], "scan_type": "quick"}'

load-examples: ## Load example data
	@echo "$(GREEN)Loading example data...$(NC)"
	$(DOCKER_COMPOSE) exec app python -m app.cli load-examples

# Performance
benchmark: ## Run performance benchmarks
	@echo "$(GREEN)Running benchmarks...$(NC)"
	$(DOCKER_COMPOSE) exec app python -m pytest tests/performance/ -v

# Security
generate-certs: ## Generate SSL certificates
	@echo "$(GREEN)Generating SSL certificates...$(NC)"
	chmod +x scripts/generate-certs.sh
	./scripts/generate-certs.sh

audit: ## Run security audit
	@echo "$(GREEN)Running security audit...$(NC)"
	$(DOCKER_COMPOSE) exec app pip-audit
	$(MAKE) security-scan
