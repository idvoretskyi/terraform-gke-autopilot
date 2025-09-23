# Simplified Root Outputs

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

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${module.gke_autopilot.cluster_name} --region ${module.gke_autopilot.region} --project ${module.gke_autopilot.project_id}"
}

output "cluster_labels" {
  description = "Applied cluster labels for cost tracking"
  value       = module.gke_autopilot.cluster_labels
}