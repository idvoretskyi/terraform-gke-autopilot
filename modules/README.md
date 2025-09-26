# Terraform Modules

This directory contains reusable Terraform modules for infrastructure deployment.

## Available Modules

### gke-autopilot

A simplified, production-ready Terraform module for deploying Google Kubernetes Engine (GKE) Autopilot clusters with cost optimization and best practices.

**Features:**
- ✨ **Simplified Configuration** - Minimal variables, smart defaults
- 💰 **Cost-Optimized** - Efficient logging/monitoring, regional deployment
- 🔒 **Security-First** - Workload Identity, STABLE release channel
- 🚀 **Production-Ready** - Maintenance windows, proper labeling
- 📊 **Autopilot Benefits** - Serverless nodes, pay-per-workload pricing

**Quick Usage:**
```hcl
module "gke_cluster" {
  source = "./modules/gke-autopilot"

  cluster_name = "my-autopilot-cluster"
  region       = "us-central1"
  environment  = "production"
}
```

**Key Variables:**
| Variable | Description | Default |
|----------|-------------|---------|
| `cluster_name` | Name of the GKE cluster | `"autopilot-cluster"` |
| `region` | GCP region for deployment | `""` (uses gcloud config) |
| `project_id` | GCP project ID | `""` (uses gcloud config) |
| `environment` | Environment label | `"dev"` |
| `cost_center` | Cost center for billing | `"engineering"` |
| `release_channel` | GKE release channel | `"STABLE"` |
| `deletion_protection` | Enable deletion protection | `false` |

**Outputs:**
- `cluster_name` - The name of the created cluster
- `cluster_host` - The cluster endpoint (sensitive)
- `cluster_ca_certificate` - The cluster CA certificate (sensitive)
- `region` - The region where the cluster is deployed
- `project_id` - The GCP project ID
- `cluster_location` - The cluster location
- `workload_identity_pool` - Workload Identity pool for service accounts
- `cluster_version` - Current master version of the cluster
- `cluster_labels` - Labels applied to the cluster

**Requirements:**
- Terraform >= 1.0
- Google Provider >= 4.47.0, < 7.4
- Authenticated gcloud CLI or Application Default Credentials

**Important Notes:**
- ⚠️ **Autopilot clusters are always regional** (zonal not supported)
- 🔧 **Automatic node management** - No need to manage node pools
- 💡 **Smart fallbacks** - Uses gcloud config when variables not provided
- 🏷️ **Proper labeling** - Includes environment, cost center, and management tags

For detailed usage and advanced configuration, see the main project README.md.