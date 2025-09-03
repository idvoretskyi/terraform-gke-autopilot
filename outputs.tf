# Cluster information
output "kubernetes_cluster_name" {
  description = "GKE Cluster Name"
  value       = module.gke_autopilot.cluster_name
}

output "kubernetes_cluster_host" {
  description = "GKE Cluster Host"
  value       = module.gke_autopilot.cluster_host
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE Cluster CA Certificate"
  value       = module.gke_autopilot.cluster_ca_certificate
  sensitive   = true
}

output "region" {
  description = "GCP Region"
  value       = module.gke_autopilot.region
}

output "project_id" {
  description = "GCP Project ID"
  value       = module.gke_autopilot.project_id
}

output "cluster_location" {
  description = "Cluster location"
  value       = module.gke_autopilot.cluster_location
}

output "workload_identity_pool" {
  description = "Workload Identity pool"
  value       = module.gke_autopilot.workload_identity_pool
}

# kubectl configuration command
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${module.gke_autopilot.cluster_name} --region ${module.gke_autopilot.region} --project ${module.gke_autopilot.project_id}"
}

# Cost optimization info
output "cluster_labels" {
  description = "Applied cluster labels for cost tracking"
  value       = module.gke_autopilot.cluster_labels
}

# Dynamic configuration info
output "gcloud_config_used" {
  description = "Gcloud configuration values that were dynamically detected"
  value       = module.gke_autopilot.gcloud_config_used
}

output "config_source" {
  description = "Source of configuration values (shows what was used: variable, gcloud, or default)"
  value       = module.gke_autopilot.config_source
}