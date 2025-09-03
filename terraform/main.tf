terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.47.0"
    }
  }
}

# Access current gcloud CLI config (project, region/zone)
data "google_client_config" "current" {}

locals {
  # Determine region priority: explicit var > gcloud region > derive from gcloud zone
  derived_region = replace(coalesce(data.google_client_config.current.zone, ""), "-[a-z]$", "")
  region         = var.region != "" ? var.region : (coalesce(data.google_client_config.current.region, "") != "" ? data.google_client_config.current.region : (local.derived_region != "" ? local.derived_region : "us-central1"))

  # Determine project from var or gcloud config
  project_id = var.project_id != "" ? var.project_id : data.google_client_config.current.project
}

resource "google_container_cluster" "autopilot_cluster" {
  name     = var.cluster_name
  location = local.region
  project  = local.project_id

  # Autopilot for serverless, pay-per-request resources
  enable_autopilot = true

  # Labels for governance and ownership
  resource_labels = {
    environment = var.environment
    owner       = var.owner_label
  }

  # Conservative channel for stability and predictable behavior
  release_channel {
    channel = "STABLE"
  }

  # Maintenance during off-hours to minimize disruption
  maintenance_policy {
    recurring_window {
      start_time = "2022-01-01T00:00:00Z"
      end_time   = "2022-01-01T06:00:00Z"
      recurrence = "FREQ=DAILY"
    }
  }

  # Workload Identity for secure, keyless access to Google APIs
  workload_identity_config {
    workload_pool = "${local.project_id}.svc.id.goog"
  }

  # Master Authorized Networks - restrict API server access (replace with trusted CIDRs)
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.master_cidr
      display_name = "trusted"
    }
  }

  # Disable client certificate authentication
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # RBAC via Google Groups for GKE
  authenticator_groups_config {
    security_group = var.rbac_security_group
  }

  # Intranode visibility cannot be enabled on Autopilot

  # Autopilot manages IPs; keep minimal explicit config
  # GKE Autopilot enforces GKE Metadata Server and Workload Identity; node_config not configurable
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Cost-efficient observability: limit to system components
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  lifecycle {
    ignore_changes = []
  }
  # Use the dedicated VPC/subnet with secondary ranges
  network    = google_compute_network.gke.id
  subnetwork = google_compute_subnetwork.gke.name
}

# Minimal VPC and subnet with flow logs enabled for the cluster (optional but recommended)
resource "google_compute_network" "gke" {
  name                    = "gke-autopilot-net"
  project                 = local.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke" {
  name          = "gke-autopilot-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = local.region
  network       = google_compute_network.gke.id
  project       = local.project_id

  # purpose = "PRIVATE"  # Dropped to avoid invalid values

  # Enable VPC flow logs via log_config (enable_flow_logs is deprecated)
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}
