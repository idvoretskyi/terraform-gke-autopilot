#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Running unit tests"

# --- Terraform ---
echo ""
echo "--- Terraform (root) ---"
cd "$ROOT_DIR"
terraform init -backend=false -upgrade -no-color
terraform validate -no-color
echo "Root config valid."

echo ""
echo "--- Terraform (module) ---"
terraform -chdir=modules/gke-autopilot init -backend=false -upgrade -no-color
terraform -chdir=modules/gke-autopilot validate -no-color
echo "Module config valid."

echo ""
echo "--- Terraform formatting ---"
if ! terraform fmt -check -recursive .; then
	echo "ERROR: Terraform formatting issues found. Run 'terraform fmt -recursive .' to fix."
	exit 1
fi
echo "Formatting OK."

# --- Go Application ---
echo ""
echo "--- Go application ---"
if command -v go &>/dev/null; then
	cd "$ROOT_DIR/app"
	go test -v -race ./...
	echo "Go tests passed."
else
	echo "SKIP: Go is not installed."
fi

echo ""
echo "==> All tests passed."
