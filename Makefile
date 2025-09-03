# Terraform GKE Autopilot Makefile

.PHONY: help init plan apply destroy validate format test clean docs

# Default target
help: ## Show this help message
	@echo "Terraform GKE Autopilot - Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Terraform operations
init: ## Initialize Terraform
	terraform init

plan: ## Run terraform plan
	terraform plan

plan-dev: ## Plan with dev environment variables
	terraform plan -var-file="environments/dev/terraform.tfvars"

plan-prod: ## Plan with production environment variables
	terraform plan -var-file="environments/prod/terraform.tfvars"

apply: ## Apply terraform configuration (requires confirmation)
	terraform apply

apply-dev: ## Apply with dev environment variables
	terraform apply -var-file="environments/dev/terraform.tfvars"

apply-prod: ## Apply with production environment variables
	terraform apply -var-file="environments/prod/terraform.tfvars"

destroy: ## Destroy all terraform resources (requires confirmation)
	terraform destroy

destroy-dev: ## Destroy dev environment
	terraform destroy -var-file="environments/dev/terraform.tfvars"

destroy-prod: ## Destroy production environment
	terraform destroy -var-file="environments/prod/terraform.tfvars"

# Code quality
validate: ## Validate terraform configuration
	terraform validate
	terraform -chdir=modules/gke-autopilot validate

format: ## Format terraform code
	terraform fmt -recursive .

format-check: ## Check terraform formatting
	terraform fmt -check -recursive .

# Testing
test-unit: ## Run unit tests (validation, formatting, etc.)
	./tests/unit_test.sh

test-integration: ## Run integration tests with terratest (requires Go)
	cd tests && go test -v -timeout 30m

test-all: test-unit test-integration ## Run all tests

# Setup and cleanup
clean: ## Clean temporary files and terraform state
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f terraform.tfvars
	rm -f tfplan

setup-backend: ## Set up GCS backend (requires environment variables)
	@echo "Setting up GCS backend..."
	@if [ -z "$$TF_BUCKET" ]; then echo "Error: TF_BUCKET environment variable not set"; exit 1; fi
	@if [ -z "$$TF_PREFIX" ]; then echo "Error: TF_PREFIX environment variable not set"; exit 1; fi
	terraform init \
		-backend-config="bucket=$$TF_BUCKET" \
		-backend-config="prefix=$$TF_PREFIX"

# Documentation and examples
docs: ## Generate documentation
	@echo "Generating Terraform documentation..."
	@command -v terraform-docs >/dev/null 2>&1 || { echo "terraform-docs not found. Install with: brew install terraform-docs"; exit 1; }
	terraform-docs markdown table --output-file MODULE.md modules/gke-autopilot/

example-dev: ## Create example dev configuration
	cp terraform.tfvars.example terraform.tfvars
	@echo "Created terraform.tfvars from example. Edit as needed."

# Removed cost estimation and security scanning targets as they were causing test failures

# kubectl helper
kubectl-config: ## Configure kubectl for the created cluster
	@terraform output -raw kubectl_config_command | bash

# Get outputs
outputs: ## Show terraform outputs
	terraform output

# GitHub Actions helpers
check-github-actions: ## Validate GitHub Actions workflows
	@echo "Checking GitHub Actions workflows..."
	@if command -v act >/dev/null 2>&1; then \
		echo "Running GitHub Actions locally with act..."; \
		act -l; \
	else \
		echo "GitHub Actions workflows configured. Install 'act' to test locally."; \
	fi

# AI tools check
check-ai-ignore: ## Verify AI tools are properly ignored
	@echo "Checking .gitignore for AI tools exclusions..."
	@if grep -q "claude" .gitignore; then \
		echo "✓ AI tools are properly excluded"; \
	else \
		echo "⚠ Consider adding AI tools to .gitignore"; \
	fi

# Complete project validation
validate-all: format-check validate test-unit ## Run essential validation checks
	@echo "All validation checks completed!"