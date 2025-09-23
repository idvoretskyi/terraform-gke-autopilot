# Simplified Module Outputs

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

output "cluster_location" {
  description = "Cluster location (region)"
  value       = google_container_cluster.autopilot_cluster.location
}

output "workload_identity_pool" {
  description = "Workload Identity pool for service account binding"
  value       = google_container_cluster.autopilot_cluster.workload_identity_config[0].workload_pool
}

output "cluster_version" {
  description = "Current master version of the cluster"
  value       = google_container_cluster.autopilot_cluster.master_version
}

output "cluster_labels" {
  description = "Labels applied to the cluster"
  value       = google_container_cluster.autopilot_cluster.resource_labels
}