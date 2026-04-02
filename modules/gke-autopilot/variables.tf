# GKE Autopilot Module Variables
#
# This module expects all values to be passed from the root module.
# Defaults are omitted here to avoid duplication with root variables.tf.
# For standalone usage, provide values via terraform.tfvars.

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,38}[a-z0-9]$", var.cluster_name))
    error_message = "Cluster name must start with a lowercase letter, contain only lowercase letters, numbers, and hyphens, end with a letter or number, and be between 2-40 characters."
  }
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
}

variable "cost_center" {
  description = "Cost center for billing allocation"
  type        = string
}

variable "release_channel" {
  description = "GKE release channel (RAPID, REGULAR, STABLE)"
  type        = string

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "Release channel must be one of: RAPID, REGULAR, STABLE."
  }
}

variable "deletion_protection" {
  description = "Enable deletion protection for the cluster"
  type        = bool
}

variable "logging_components" {
  description = "List of logging components to enable"
  type        = list(string)
}

variable "monitoring_components" {
  description = "List of monitoring components to enable"
  type        = list(string)
}

# Networking variables (extracted from hardcoded values)

variable "subnet_cidr" {
  description = "Primary CIDR range for the VPC subnet"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr must be a valid CIDR block."
  }
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE pods"
  type        = string
  default     = "10.1.0.0/16"

  validation {
    condition     = can(cidrhost(var.pods_cidr, 0))
    error_message = "pods_cidr must be a valid CIDR block."
  }
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE services"
  type        = string
  default     = "10.2.0.0/16"

  validation {
    condition     = can(cidrhost(var.services_cidr, 0))
    error_message = "services_cidr must be a valid CIDR block."
  }
}
