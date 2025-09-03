# Required variables
variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "autopilot-cluster"

  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]{0,38}[a-z0-9])?$", var.cluster_name))
    error_message = "Cluster name must be lowercase, start with a letter, and be 1-40 characters long with hyphens allowed."
  }
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
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
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

# Cluster configuration variables
variable "release_channel" {
  description = "The release channel for GKE cluster"
  type        = string
  default     = "STABLE"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "Release channel must be RAPID, REGULAR, or STABLE."
  }
}

variable "maintenance_start_time" {
  description = "Start time for maintenance window (RFC3339 format)"
  type        = string
  default     = "2022-01-01T02:00:00Z"
}

variable "maintenance_end_time" {
  description = "End time for maintenance window (RFC3339 format)"
  type        = string
  default     = "2022-01-01T06:00:00Z"
}

variable "maintenance_recurrence" {
  description = "Maintenance window recurrence pattern"
  type        = string
  default     = "FREQ=DAILY"
}

# Private cluster variables
variable "enable_private_cluster" {
  description = "Enable private cluster configuration for enhanced security"
  type        = bool
  default     = false
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for the cluster master"
  type        = bool
  default     = false
}

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

# Observability variables
variable "logging_components" {
  description = "List of logging components to enable"
  type        = list(string)
  default     = ["SYSTEM_COMPONENTS"]

  validation {
    condition = alltrue([
      for component in var.logging_components : contains([
        "SYSTEM_COMPONENTS", "WORKLOADS", "API_SERVER", "CONTROLLER_MANAGER", "SCHEDULER"
      ], component)
    ])
    error_message = "Invalid logging component specified."
  }
}

variable "monitoring_components" {
  description = "List of monitoring components to enable"
  type        = list(string)
  default     = ["SYSTEM_COMPONENTS"]

  validation {
    condition = alltrue([
      for component in var.monitoring_components : contains([
        "SYSTEM_COMPONENTS", "WORKLOADS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER"
      ], component)
    ])
    error_message = "Invalid monitoring component specified."
  }
}

variable "enable_managed_prometheus" {
  description = "Enable Google Managed Prometheus"
  type        = bool
  default     = false
}

# Security variables
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

# Autoscaling variables
variable "enable_cluster_autoscaling" {
  description = "Enable cluster autoscaling for cost optimization"
  type        = bool
  default     = true
}

variable "min_cpu_cores" {
  description = "Minimum CPU cores for cluster autoscaling"
  type        = number
  default     = 1
}

variable "max_cpu_cores" {
  description = "Maximum CPU cores for cluster autoscaling"
  type        = number
  default     = 100
}

variable "min_memory_gb" {
  description = "Minimum memory in GB for cluster autoscaling"
  type        = number
  default     = 1
}

variable "max_memory_gb" {
  description = "Maximum memory in GB for cluster autoscaling"
  type        = number
  default     = 1000
}

# Cost management
variable "enable_cost_management" {
  description = "Enable GKE cost management features"
  type        = bool
  default     = true
}

