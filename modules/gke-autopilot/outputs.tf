output "cluster_name" {
  description = "GKE Cluster Name"
  value       = google_container_cluster.autopilot_cluster.name
}

output "cluster_host" {
  description = "GKE Cluster Host"
  value       = google_container_cluster.autopilot_cluster.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE Cluster CA Certificate"
  value       = google_container_cluster.autopilot_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "region" {
  description = "GCP Region"
  value       = local.region
}

output "project_id" {
  description = "GCP Project ID"
  value       = local.project_id
}

output "cluster_id" {
  description = "Cluster ID for referencing in other resources"
  value       = google_container_cluster.autopilot_cluster.id
}

output "cluster_location" {
  description = "Cluster location (region or zone)"
  value       = google_container_cluster.autopilot_cluster.location
}

output "workload_identity_pool" {
  description = "Workload Identity pool for service account binding"
  value       = google_container_cluster.autopilot_cluster.workload_identity_config[0].workload_pool
}

output "cluster_ipv4_cidr" {
  description = "The IP address range of the Kubernetes pods"
  value       = google_container_cluster.autopilot_cluster.cluster_ipv4_cidr
}

output "services_ipv4_cidr" {
  description = "The IP address range of the Kubernetes services"
  value       = google_container_cluster.autopilot_cluster.services_ipv4_cidr
}

output "cluster_version" {
  description = "Current master version of the cluster"
  value       = google_container_cluster.autopilot_cluster.master_version
}

output "cluster_labels" {
  description = "Labels applied to the cluster"
  value       = google_container_cluster.autopilot_cluster.resource_labels
}

# Dynamic configuration visibility
output "gcloud_config_used" {
  description = "Gcloud configuration values that were dynamically detected"
  value = {
    project_id = local.project_id
    region     = local.region
    account    = local.gcloud_account
    zone       = local.gcloud_zone
  }
}

output "config_source" {
  description = "Source of configuration values (variable, gcloud, or default)"
  value = {
    project_id_source = var.project_id != "" ? "variable" : (local.gcloud_project != "" ? "gcloud" : "terraform_data_source")
    region_source     = var.region != "" ? "variable" : (local.gcloud_region != "" ? "gcloud" : (local.gcloud_zone != "" ? "derived_from_zone" : "default"))
  }
}