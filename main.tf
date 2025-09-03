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
  # backend "gcs" {}  # Commented out to use local state
}

provider "google" {
  # Credentials and project can be inferred from gcloud auth/application-default credentials.
}

# Get current username dynamically
data "external" "current_user" {
  program = ["bash", "-c", "echo '{\"username\":\"'$(whoami)'\"}'"]
}

module "gke_autopilot" {
  source = "./modules/gke-autopilot"

  # Basic configuration
  cluster_name = var.cluster_name != "autopilot-cluster" ? var.cluster_name : "${data.external.current_user.result.username}-autopilot-cluster"
  region       = var.region
  project_id   = var.project_id
  environment  = var.environment

  # Cost optimization settings
  cost_center                = var.cost_center
  labels                     = var.labels
  enable_cluster_autoscaling = var.enable_cluster_autoscaling
  enable_cost_management     = var.enable_cost_management

  # Observability settings (cost-optimized defaults)
  logging_components        = var.logging_components
  monitoring_components     = var.monitoring_components
  enable_managed_prometheus = var.enable_managed_prometheus

  # Security settings
  enable_private_cluster      = var.enable_private_cluster
  enable_private_endpoint     = var.enable_private_endpoint
  enable_network_policy       = var.enable_network_policy
  enable_binary_authorization = var.enable_binary_authorization

  # Network configuration
  master_ipv4_cidr_block   = var.master_ipv4_cidr_block
  cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr_block
  services_ipv4_cidr_block = var.services_ipv4_cidr_block

  # Resource limits for cost control
  min_cpu_cores = var.min_cpu_cores
  max_cpu_cores = var.max_cpu_cores
  min_memory_gb = var.min_memory_gb
  max_memory_gb = var.max_memory_gb

  # Maintenance window
  maintenance_start_time = var.maintenance_start_time
  maintenance_end_time   = var.maintenance_end_time
  release_channel        = var.release_channel
}