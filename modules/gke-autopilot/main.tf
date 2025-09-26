# Simplified GKE Autopilot Module
data "google_client_config" "current" {}

locals {
  # Simple configuration resolution with fallbacks
  project_id = var.project_id != "" ? var.project_id : data.google_client_config.current.project
  region     = var.region != "" ? var.region : coalesce(data.google_client_config.current.region, "us-central1")
}

resource "google_container_cluster" "autopilot_cluster" {
  name     = var.cluster_name
  location = local.region # Autopilot requires regional clusters
  project  = local.project_id

  # Enable Autopilot mode
  enable_autopilot    = true
  deletion_protection = var.deletion_protection

  # Release channel for updates
  release_channel {
    channel = var.release_channel
  }

  # Maintenance window
  maintenance_policy {
    recurring_window {
      start_time = "2022-01-01T02:00:00Z"
      end_time   = "2022-01-01T06:00:00Z"
      recurrence = "FREQ=DAILY"
    }
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${local.project_id}.svc.id.goog"
  }

  # Cost-optimized logging and monitoring
  logging_config {
    enable_components = var.logging_components
  }
  monitoring_config {
    enable_components = var.monitoring_components
  }

  # Labels for resource management
  resource_labels = {
    environment = var.environment
    managed_by  = "terraform"
    cost_center = var.cost_center
  }
}