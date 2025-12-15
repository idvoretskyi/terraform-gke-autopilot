# Simplified GKE Autopilot Module
data "google_client_config" "current" {}

locals {
  # Simple configuration resolution with fallbacks
  project_id = var.project_id != "" ? var.project_id : data.google_client_config.current.project
  region     = var.region != "" ? var.region : coalesce(data.google_client_config.current.region, "us-central1")
}

resource "google_compute_network" "vpc" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
  project                 = local.project_id
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.cluster_name}-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = local.region
  network       = google_compute_network.vpc.id
  project       = local.project_id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

resource "google_container_cluster" "autopilot_cluster" {
  name     = var.cluster_name
  location = local.region # Autopilot requires regional clusters
  project  = local.project_id

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

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

  # Cost Management
  cost_management_config {
    enabled = true
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
