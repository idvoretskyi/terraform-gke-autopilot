# Terraform Modules

This directory contains reusable Terraform modules for infrastructure deployment.

## Available Modules

### gke-autopilot

A production-ready Terraform module for deploying Google Kubernetes Engine (GKE) Autopilot clusters with cost optimization and security best practices.

**Features:**
- Simplified configuration with smart defaults
- Cost-optimized logging and monitoring
- Workload Identity for secure, keyless GCP access
- Configurable networking (VPC, subnet, pod/service CIDRs)
- Maintenance windows and proper resource labeling
- Deletion protection enabled by default

**Usage:**
```hcl
module "gke_cluster" {
  source = "./modules/gke-autopilot"

  cluster_name        = "my-autopilot-cluster"
  region              = "us-central1"
  environment         = "production"
  cost_center         = "engineering"
  release_channel     = "REGULAR"
  deletion_protection = true
  logging_components    = ["SYSTEM_COMPONENTS"]
  monitoring_components = ["SYSTEM_COMPONENTS"]
}
```

**Variables:**

| Variable | Description | Default |
|----------|-------------|---------|
| `cluster_name` | Name of the GKE cluster | (required) |
| `region` | GCP region | `""` (uses gcloud config) |
| `project_id` | GCP project ID | `""` (uses gcloud config) |
| `environment` | Environment label | (required) |
| `cost_center` | Cost center for billing | (required) |
| `release_channel` | GKE release channel | (required) |
| `deletion_protection` | Enable deletion protection | (required) |
| `subnet_cidr` | Primary subnet CIDR | `"10.0.0.0/16"` |
| `pods_cidr` | Pod secondary range CIDR | `"10.1.0.0/16"` |
| `services_cidr` | Services secondary range CIDR | `"10.2.0.0/16"` |

**Outputs:**
- `cluster_name` — the name of the created cluster
- `cluster_host` — the cluster endpoint (sensitive)
- `cluster_ca_certificate` — the cluster CA certificate (sensitive)
- `cluster_version` — current master version
- `region` — region where the cluster is deployed
- `project_id` — GCP project ID
- `cluster_location` — cluster location
- `workload_identity_pool` — Workload Identity pool
- `cluster_labels` — labels applied to the cluster

**Requirements:**
- Terraform >= 1.0
- Google Provider >= 4.47.0, < 8.0
- Authenticated gcloud CLI or Application Default Credentials

**Notes:**
- Autopilot clusters are always regional (zonal not supported)
- Uses gcloud config as fallback when `project_id` / `region` are empty
- For standalone validation: `terraform -chdir=modules/gke-autopilot validate`
