#!/usr/bin/env bash

set -e

echo "Running unit tests..."

# Change to the root directory
cd "$(dirname "$0")/.."

# --- Terraform Tests ---
echo "--- Terraform ---"
echo "Validating main Terraform configuration..."
terraform init -backend=false
terraform validate

echo "Validating module Terraform configuration..."
cd modules/gke-autopilot
terraform init -backend=false
terraform validate
cd ../..

echo "Checking Terraform formatting..."
if ! terraform fmt -check -recursive .; then
    echo "Terraform formatting issues found. Run 'terraform fmt -recursive .' to fix."
    exit 1
fi

# --- Go Application Tests ---
echo "--- Go Application ---"
echo "Running Go unit tests..."
cd app
if command -v go &> /dev/null; then
    go test -v ./...
else
    echo "Go is not installed. Skipping Go tests."
fi
cd ..

echo "All unit tests passed successfully!"