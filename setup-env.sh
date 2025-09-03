#!/bin/bash
set -euo pipefail

# Helper to run terraform commands in the consolidated directory
TF_DIR="$(cd "$(dirname "$0")" && pwd)/terraform"

PROJECT=$(gcloud config get-value project 2>/dev/null || true)
REGION=$(gcloud config get-value compute/region 2>/dev/null || true)
ZONE=$(gcloud config get-value compute/zone 2>/dev/null || true)

echo "Using gcloud project: ${PROJECT:-<auto>}"
echo "Using gcloud region:  ${REGION:-<auto>}"
echo "Using gcloud zone:    ${ZONE:-<auto>}"

cd "$TF_DIR"

cmd="${1:-}"
shift || true

case "$cmd" in
	init-remote)
		TF_BUCKET="${TF_BUCKET:-${PROJECT}-tf-state}"
		TF_PREFIX="${TF_PREFIX:-gke-autopilot/terraform}"
		TF_REGION="${TF_REGION:-${REGION:-us-central1}}"

		echo "Preparing GCS bucket: gs://$TF_BUCKET (region: $TF_REGION)"
		gcloud storage buckets create "gs://$TF_BUCKET" \
			--project "$PROJECT" \
			--location "$TF_REGION" \
			--uniform-bucket-level-access \
			--no-public-access || true

		terraform init -migrate-state \
			-backend-config="bucket=$TF_BUCKET" \
			-backend-config="prefix=$TF_PREFIX" "$@"
		;;
	init|plan|apply|destroy|validate|fmt|providers|output|state)
		if [[ -n "${PROJECT:-}" ]]; then
			terraform "$cmd" -var="project_id=$PROJECT" "$@"
		else
			terraform "$cmd" "$@"
		fi
		;;
	*)
		if [[ -n "${PROJECT:-}" ]]; then
			terraform "$cmd" -var="project_id=$PROJECT" "$@"
		else
			terraform "$cmd" "$@"
		fi
		;;
esac
