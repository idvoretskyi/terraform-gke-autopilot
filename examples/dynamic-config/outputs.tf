# Outputs showing dynamic configuration in action

output "cluster_name" {
  description = "Name of the created GKE cluster"
  value       = module.gke_autopilot_dynamic.cluster_name
}

output "detected_gcloud_config" {
  description = "Shows what gcloud configuration values were automatically detected"
  value       = module.gke_autopilot_dynamic.gcloud_config_used
}

output "config_source_info" {
  description = "Shows the source of each configuration value (variable, gcloud, or default)"
  value       = module.gke_autopilot_dynamic.config_source
}

output "kubectl_command" {
  description = "Command to configure kubectl (using detected project and region)"
  value       = "gcloud container clusters get-credentials ${module.gke_autopilot_dynamic.cluster_name} --region ${module.gke_autopilot_dynamic.region} --project ${module.gke_autopilot_dynamic.project_id}"
}