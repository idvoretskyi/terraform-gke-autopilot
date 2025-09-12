# Basic configuration
variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "autopilot-cluster"
}

variable "region" {
  description = "The region to deploy to. Used for regional clusters. If empty, uses gcloud region or derives from zone."
  type        = string
  default     = ""
}

variable "zone" {
  description = "The zone to deploy to. Used for zonal clusters (cost-effective). If empty, uses gcloud zone."
  type        = string
  default     = ""
}

variable "cluster_type" {
  description = "Cluster type: 'regional' for high availability (required for Autopilot)"
  type        = string
  default     = "regional"
}

variable "project_id" {
  description = "The GCP project ID. If empty, uses the current gcloud project from your CLI config."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Cost optimization variables
variable "cost_center" {
  description = "Cost center for billing allocation"
  type        = string
  default     = "engineering"
}

variable "labels" {
  description = "Additional labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_cluster_autoscaling" {
  description = "Enable cluster autoscaling for cost optimization"
  type        = bool
  default     = true
}

variable "enable_cost_management" {
  description = "Enable GKE cost management features"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection for the cluster"
  type        = bool
  default     = false
}

# Resource limits for cost control
variable "min_cpu_cores" {
  description = "Minimum CPU cores for cluster autoscaling"
  type        = number
  default     = 1
}

variable "max_cpu_cores" {
  description = "Maximum CPU cores for cluster autoscaling (keep low for cost control)"
  type        = number
  default     = 50
}

variable "min_memory_gb" {
  description = "Minimum memory in GB for cluster autoscaling"
  type        = number
  default     = 1
}

variable "max_memory_gb" {
  description = "Maximum memory in GB for cluster autoscaling (keep reasonable for cost control)"
  type        = number
  default     = 200
}

# Observability settings (cost-optimized defaults)
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

variable "enable_managed_prometheus" {
  description = "Enable Google Managed Prometheus (additional cost)"
  type        = bool
  default     = false
}

# Security settings
variable "enable_private_cluster" {
  description = "Enable private cluster configuration"
  type        = bool
  default     = false
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for the cluster master"
  type        = bool
  default     = false
}

variable "enable_network_policy" {
  description = "Enable network policy addon"
  type        = bool
  default     = false
}

variable "enable_binary_authorization" {
  description = "Enable Binary Authorization"
  type        = bool
  default     = false
}

# Network configuration
variable "master_ipv4_cidr_block" {
  description = "CIDR block for the master network"
  type        = string
  default     = "10.0.0.0/28"
}

variable "cluster_ipv4_cidr_block" {
  description = "CIDR block for cluster pods"
  type        = string
  default     = ""
}

variable "services_ipv4_cidr_block" {
  description = "CIDR block for services"
  type        = string
  default     = ""
}

# Maintenance window (cost-optimized for off-hours)
variable "maintenance_start_time" {
  description = "Start time for maintenance window (off-hours)"
  type        = string
  default     = "2022-01-01T02:00:00Z"
}

variable "maintenance_end_time" {
  description = "End time for maintenance window"
  type        = string
  default     = "2022-01-01T06:00:00Z"
}

variable "release_channel" {
  description = "Release channel (RAPID for latest Kubernetes versions)"
  type        = string
  default     = "RAPID"
}