# Simplified GKE Autopilot Variables

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "autopilot-cluster"
}

variable "region" {
  description = "The region to deploy to. If empty, uses gcloud region"
  type        = string
  default     = ""
}

variable "project_id" {
  description = "The GCP project ID. If empty, uses current gcloud project"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "cost_center" {
  description = "Cost center for billing allocation"
  type        = string
  default     = "engineering"
}

variable "release_channel" {
  description = "GKE release channel (RAPID, REGULAR, STABLE)"
  type        = string
  default     = "STABLE"
}

variable "deletion_protection" {
  description = "Enable deletion protection for the cluster"
  type        = bool
  default     = false
}

variable "logging_components" {
  description = "List of logging components to enable"
  type        = list(string)
  default     = ["SYSTEM_COMPONENTS"]
}

variable "monitoring_components" {
  description = "List of monitoring components to enable"
  type        = list(string)
  default     = ["SYSTEM_COMPONENTS"]
}