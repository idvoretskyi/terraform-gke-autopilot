#!/usr/bin/env bash

set -e

echo "Running Terraform unit tests..."

# Change to the root directory
cd "$(dirname "$0")/.."

# Initialize and validate main configuration
echo "Validating main Terraform configuration..."
terraform init
terraform validate

# Initialize and validate module configuration
echo "Validating module Terraform configuration..."
cd modules/gke-autopilot
terraform init
terraform validate
cd ../..

# Run terraform fmt check
echo "Checking Terraform formatting..."
if ! terraform fmt -check -recursive .; then
    echo "Terraform formatting issues found. Run 'terraform fmt -recursive .' to fix."
    exit 1
fi

echo "All unit tests passed successfully!"