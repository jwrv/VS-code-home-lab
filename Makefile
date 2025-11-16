.PHONY: help build start stop restart clean deploy k8s-deploy k8s-delete logs shell

# Default target
.DEFAULT_GOAL := help

# Variables
COMPOSE_FILE := docker-compose.yml
K8S_DIR := kubernetes
NAMESPACE := development

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Docker Compose commands
build: ## Build the Docker container
	docker-compose -f $(COMPOSE_FILE) build

start: ## Start VS Code server with Docker Compose
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "VS Code server starting at http://localhost:8080"

stop: ## Stop VS Code server
	docker-compose -f $(COMPOSE_FILE) down

restart: stop start ## Restart VS Code server

logs: ## View VS Code server logs
	docker-compose -f $(COMPOSE_FILE) logs -f vscode-server

shell: ## Open shell in VS Code container
	docker-compose -f $(COMPOSE_FILE) exec vscode-server /bin/bash

clean: ## Remove containers, volumes, and images
	docker-compose -f $(COMPOSE_FILE) down -v
	docker system prune -f

# Kubernetes commands
k8s-apply: ## Deploy to Kubernetes
	kubectl apply -k $(K8S_DIR)
	@echo "Waiting for deployment..."
	kubectl wait --for=condition=available --timeout=300s \
		deployment/vscode-server -n $(NAMESPACE) || true
	@echo ""
	@echo "Deployment complete!"
	@kubectl get pods -n $(NAMESPACE) -l app=vscode-server

k8s-delete: ## Delete from Kubernetes
	kubectl delete -k $(K8S_DIR)

k8s-status: ## Check Kubernetes deployment status
	kubectl get all -n $(NAMESPACE) -l app=vscode-server
	@echo ""
	kubectl get ingress -n $(NAMESPACE)

k8s-logs: ## View Kubernetes pod logs
	kubectl logs -n $(NAMESPACE) -l app=vscode-server --tail=100 -f

k8s-shell: ## Open shell in Kubernetes pod
	kubectl exec -it -n $(NAMESPACE) deployment/vscode-server -- /bin/bash

k8s-restart: ## Restart Kubernetes deployment
	kubectl rollout restart deployment/vscode-server -n $(NAMESPACE)
	kubectl rollout status deployment/vscode-server -n $(NAMESPACE)

k8s-port-forward: ## Port forward to access locally
	@echo "Forwarding port 8080..."
	kubectl port-forward -n $(NAMESPACE) svc/vscode-server 8080:8080

# Configuration
create-env: ## Create .env file from example
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo ".env file created. Please edit with your values."; \
	else \
		echo ".env file already exists."; \
	fi

validate: ## Validate configurations
	@echo "Validating Docker Compose..."
	docker-compose -f $(COMPOSE_FILE) config > /dev/null
	@echo "Validating Kubernetes manifests..."
	kubectl apply -k $(K8S_DIR) --dry-run=client > /dev/null
	@echo "All validations passed!"

# Development
dev: create-env start ## Quick start for development

deploy: ## Deploy (choose based on DEPLOY_METHOD env var)
	@if [ "$(DEPLOY_METHOD)" = "kubernetes" ]; then \
		make k8s-apply; \
	else \
		make start; \
	fi

# Monitoring
ps: ## Show running containers
	docker-compose -f $(COMPOSE_FILE) ps

stats: ## Show container stats
	docker stats homelab-vscode

# Backup
backup: ## Backup VS Code data
	@echo "Creating backup..."
	@mkdir -p backups
	@timestamp=$$(date +%Y%m%d_%H%M%S); \
	docker run --rm \
		-v homelab-vscode-config:/data/config \
		-v homelab-vscode-extensions:/data/extensions \
		-v $$(pwd)/backups:/backup \
		alpine tar czf /backup/vscode-backup-$$timestamp.tar.gz -C /data .
	@echo "Backup created in backups/ directory"

restore: ## Restore VS Code data from backup (requires BACKUP_FILE)
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "Error: BACKUP_FILE not specified"; \
		echo "Usage: make restore BACKUP_FILE=backups/vscode-backup-20240101_120000.tar.gz"; \
		exit 1; \
	fi
	@echo "Restoring from $(BACKUP_FILE)..."
	docker run --rm \
		-v homelab-vscode-config:/data/config \
		-v homelab-vscode-extensions:/data/extensions \
		-v $$(pwd)/backups:/backup \
		alpine tar xzf /backup/$$(basename $(BACKUP_FILE)) -C /data
	@echo "Restore complete"

# Testing
test: ## Run tests
	@echo "Testing Docker Compose configuration..."
	docker-compose -f $(COMPOSE_FILE) config > /dev/null && echo "✓ Docker Compose valid"
	@echo "Testing Kubernetes manifests..."
	kubectl apply -k $(K8S_DIR) --dry-run=client > /dev/null && echo "✓ Kubernetes manifests valid"

# Documentation
docs: ## Generate documentation
	@echo "Documentation available in README.md and kubernetes/README.md"
	@echo ""
	@echo "Quick links:"
	@echo "  - Main README: README.md"
	@echo "  - Kubernetes deployment: kubernetes/README.md"
	@echo "  - AI assistants: .ai-assistants/"
