# Example: Using Dynamic gcloud Configuration
# This example shows how to use the module with automatic gcloud config detection

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.47.0, < 7.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.0"
    }
  }
}

provider "google" {
  # Credentials and project will be automatically detected from:
  # 1. Application Default Credentials (gcloud auth application-default login)
  # 2. Service Account Key (if GOOGLE_APPLICATION_CREDENTIALS is set)
  # 3. Metadata service (if running on GCP)
}

# Use the module with minimal configuration
# Project ID and region will be automatically detected from gcloud config
module "gke_autopilot_dynamic" {
  source = "../../modules/gke-autopilot"

  # Only specify what you want to customize
  cluster_name = "dynamic-autopilot-cluster"
  environment  = "dev"

  # Optional: override specific settings
  max_cpu_cores = 20
  max_memory_gb = 80

  # Project ID and region will be automatically detected from:
  # 1. Your gcloud configuration (gcloud config get-value project/compute/region)
  # 2. Terraform's google_client_config data source
  # 3. Defaults (us-central1 for region)
}