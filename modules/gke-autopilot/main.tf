# Access current gcloud CLI config (project, region/zone)
data "google_client_config" "current" {}

# External data sources to read additional gcloud configuration
data "external" "gcloud_config" {
  program = ["bash", "-c", <<-EOT
    set -e
    project=$(gcloud config get-value project 2>/dev/null || echo "")
    region=$(gcloud config get-value compute/region 2>/dev/null || echo "")
    zone=$(gcloud config get-value compute/zone 2>/dev/null || echo "")
    account=$(gcloud config get-value account 2>/dev/null || echo "")
    
    # Derive region from zone if region is not set
    if [ -z "$region" ] && [ -n "$zone" ]; then
      region=$(echo "$zone" | sed 's/-[a-z]$//')
    fi
    
    # Output as JSON
    jq -n \
      --arg project "$project" \
      --arg region "$region" \
      --arg zone "$zone" \
      --arg account "$account" \
      '{project: $project, region: $region, zone: $zone, account: $account}'
  EOT
  ]
}

locals {
  # Dynamic configuration with fallback hierarchy:
  # 1. Explicit variable values
  # 2. gcloud CLI configuration
  # 3. Terraform google_client_config data source
  # 4. Sensible defaults

  gcloud_project = try(data.external.gcloud_config.result.project, "")
  gcloud_region  = try(data.external.gcloud_config.result.region, "")
  gcloud_zone    = try(data.external.gcloud_config.result.zone, "")
  gcloud_account = try(data.external.gcloud_config.result.account, "")

  # Project ID resolution
  project_id = coalesce(
    var.project_id != "" ? var.project_id : null,
    local.gcloud_project != "" ? local.gcloud_project : null,
    data.google_client_config.current.project,
    ""
  )

  # Region resolution with smart fallback
  region = coalesce(
    var.region != "" ? var.region : null,
    local.gcloud_region != "" ? local.gcloud_region : null,
    data.google_client_config.current.region != null ? data.google_client_config.current.region : null,
    local.gcloud_zone != "" ? replace(local.gcloud_zone, "-[a-z]$", "") : null,
    data.google_client_config.current.zone != null ? replace(data.google_client_config.current.zone, "-[a-z]$", "") : null,
    "us-central1"
  )

  # Zone resolution with smart fallback
  zone = coalesce(
    var.zone != "" ? var.zone : null,
    local.gcloud_zone != "" ? local.gcloud_zone : null,
    data.google_client_config.current.zone != null ? data.google_client_config.current.zone : null,
    "${local.region}-a"
  )

  # Cluster location based on type
  cluster_location = var.cluster_type == "zonal" ? local.zone : local.region

  # Cost optimization labels
  common_labels = merge(var.labels, {
    environment = var.environment
    managed_by  = "terraform"
    cost_center = var.cost_center
    project     = "gke-autopilot"
  })
}

resource "google_container_cluster" "autopilot_cluster" {
  name     = var.cluster_name
  location = local.cluster_location
  project  = local.project_id

  # Autopilot for serverless, pay-per-request resources
  enable_autopilot = true
  
  # Deletion protection
  deletion_protection = var.deletion_protection

  # Conservative channel for stability and predictable behavior
  release_channel {
    channel = var.release_channel
  }

  # Maintenance during off-hours to minimize disruption
  maintenance_policy {
    recurring_window {
      start_time = var.maintenance_start_time
      end_time   = var.maintenance_end_time
      recurrence = var.maintenance_recurrence
    }
  }

  # Workload Identity for secure, keyless access to Google APIs
  workload_identity_config {
    workload_pool = "${local.project_id}.svc.id.goog"
  }

  # Autopilot manages IPs; allow customization for advanced users
  dynamic "ip_allocation_policy" {
    for_each = var.enable_private_cluster ? [1] : []
    content {
      cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr_block
      services_ipv4_cidr_block = var.services_ipv4_cidr_block
    }
  }

  # Default IP allocation for public clusters
  dynamic "ip_allocation_policy" {
    for_each = var.enable_private_cluster ? [] : [1]
    content {
      cluster_ipv4_cidr_block  = ""
      services_ipv4_cidr_block = ""
    }
  }

  # Private cluster configuration for enhanced security
  dynamic "private_cluster_config" {
    for_each = var.enable_private_cluster ? [1] : []
    content {
      enable_private_nodes    = true
      enable_private_endpoint = var.enable_private_endpoint
      master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    }
  }

  # Cost-efficient observability: configurable components
  logging_config {
    enable_components = var.logging_components
  }
  monitoring_config {
    enable_components = var.monitoring_components
    # In Autopilot clusters version 1.25+, Managed Prometheus is automatically enabled
    # managed_prometheus {
    #   enabled = var.enable_managed_prometheus
    # }
  }

  # Network policy for enhanced security
  dynamic "network_policy" {
    for_each = var.enable_network_policy ? [1] : []
    content {
      enabled = true
    }
  }

  # Binary authorization for enhanced security
  dynamic "binary_authorization" {
    for_each = var.enable_binary_authorization ? [1] : []
    content {
      evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
    }
  }

  # Resource labels for cost tracking and management
  resource_labels = local.common_labels

  # Cost optimization: cluster autoscaling (not compatible with Autopilot)
  # Autopilot manages autoscaling automatically
  # dynamic "cluster_autoscaling" {
  #   for_each = var.enable_cluster_autoscaling ? [1] : []
  #   content {
  #     enabled = true
  #     resource_limits {
  #       resource_type = "cpu"
  #       minimum       = var.min_cpu_cores
  #       maximum       = var.max_cpu_cores
  #     }
  #     resource_limits {
  #       resource_type = "memory"
  #       minimum       = var.min_memory_gb
  #       maximum       = var.max_memory_gb
  #     }
  #   }
  # }

  lifecycle {
    ignore_changes = []
  }
}

