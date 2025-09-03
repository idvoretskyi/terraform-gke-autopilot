variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "autopilot-cluster"
}

variable "region" {
  description = "The region to deploy to. If empty, uses gcloud region or derives from zone."
  type        = string
  default     = ""
}

variable "project_id" {
  description = "The GCP project ID. If empty, uses the current gcloud project from your CLI config."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment label for the cluster (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "owner_label" {
  description = "Owner label for the cluster (team or email alias)"
  type        = string
  default     = "platform"
}

variable "rbac_security_group" {
  description = "Google Group email to use for GKE RBAC (Google Groups for GKE)"
  type        = string
  default     = "gke-rbac@example.com"
}

variable "master_cidr" {
  description = "Trusted CIDR for GKE master authorized networks (replace with your corporate IP)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "subnet_cidr" {
  description = "Primary CIDR for the GKE VPC subnetwork"
  type        = string
  default     = "10.20.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary range for Pods"
  type        = string
  default     = "10.20.32.0/19"
}

variable "services_cidr" {
  description = "Secondary range for Services"
  type        = string
  default     = "10.20.64.0/22"
}
