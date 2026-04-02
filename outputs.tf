# Root Outputs

output "kubernetes_cluster_name" {
  description = "GKE cluster name"
  value       = module.gke_autopilot.cluster_name
}

output "kubernetes_cluster_host" {
  description = "GKE cluster API endpoint"
  value       = module.gke_autopilot.cluster_host
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate (base64-encoded)"
  value       = module.gke_autopilot.cluster_ca_certificate
  sensitive   = true
}

output "cluster_version" {
  description = "Current master version of the GKE cluster"
  value       = module.gke_autopilot.cluster_version
}

output "region" {
  description = "GCP region where the cluster is deployed"
  value       = module.gke_autopilot.region
}

output "project_id" {
  description = "GCP project ID"
  value       = module.gke_autopilot.project_id
}

output "cluster_location" {
  description = "Cluster location (region)"
  value       = module.gke_autopilot.cluster_location
}

output "workload_identity_pool" {
  description = "Workload Identity pool for service account binding"
  value       = module.gke_autopilot.workload_identity_pool
}

output "kubectl_config_command" {
  description = "Command to configure kubectl for this cluster"
  value       = "gcloud container clusters get-credentials ${module.gke_autopilot.cluster_name} --region ${module.gke_autopilot.region} --project ${module.gke_autopilot.project_id}"
}

output "cluster_labels" {
  description = "Labels applied to the cluster for cost tracking"
  value       = module.gke_autopilot.cluster_labels
}

