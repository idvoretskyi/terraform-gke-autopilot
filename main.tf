# Simplified GKE Autopilot Configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.47.0, < 7.7"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.0"
    }
  }
}

provider "google" {
  # Uses gcloud auth or application-default credentials
}

# Get current username for cluster naming
data "external" "current_user" {
  program = ["bash", "-c", "echo '{\"username\":\"'$(whoami)'\"}'"]
}

# GKE Autopilot Module
module "gke_autopilot" {
  source = "./modules/gke-autopilot"

  # Basic configuration
  cluster_name        = var.cluster_name != "autopilot-cluster" ? var.cluster_name : "${data.external.current_user.result.username}-autopilot-cluster"
  region              = var.region
  project_id          = var.project_id
  environment         = var.environment
  cost_center         = var.cost_center
  release_channel     = var.release_channel
  deletion_protection = var.deletion_protection

  # Observability (cost-optimized)
  logging_components    = var.logging_components
  monitoring_components = var.monitoring_components
}