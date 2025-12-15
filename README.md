# Simplified Terraform GKE Autopilot Cluster

A streamlined Terraform configuration for deploying Google Kubernetes Engine (GKE) Autopilot clusters with cost optimization and best practices.

## Features

- **Simplified Architecture**: Clean, minimal configuration focused on essential features
- **GKE Autopilot**: Fully managed Kubernetes with automatic scaling and cost optimization
- **Dedicated Networking**: Automatically provisions a VPC and Subnet for the cluster
- **Cost-Optimized**: Minimal logging/monitoring components and efficient resource usage
- **Easy Deployment**: Single command deployment with sensible defaults
- **Workload Identity**: Secure, keyless access to Google APIs
- **Sample Application**: Includes a Go web app with graceful shutdown and health checks

## Repository Structure

```
.
├── main.tf                    # Root Terraform configuration
├── variables.tf               # Configuration variables
├── outputs.tf                 # Cluster outputs
├── modules/
│   └── gke-autopilot/        # GKE Autopilot module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── app/                      # Sample Go web application
│   ├── main.go
│   ├── main_test.go
│   ├── Dockerfile
│   └── README.md
└── k8s/                      # Kubernetes manifests
    └── deployment.yaml
```

## Quick Start

### Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and authenticated
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/) for cluster management

### Deploy the Cluster

1. **Clone and navigate to the repository:**
   ```bash
   git clone <repository-url>
   cd terraform-gke-autopilot
   ```

2. **Configure your GCP project (optional):**
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   gcloud config set compute/region YOUR_REGION
   ```

3. **Deploy with Terraform:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Configure kubectl:**
   ```bash
   gcloud container clusters get-credentials <cluster-name> --region <region>
   ```

### Deploy Sample Application

1. **Build and push the container image:**
   ```bash
   cd app
   gcloud builds submit --tag gcr.io/$(gcloud config get-value project)/demo-go-app:latest .
   ```

2. **Deploy to Kubernetes:**
   ```bash
   kubectl apply -f ../k8s/deployment.yaml
   ```

3. **Get the external IP:**
   ```bash
   kubectl get service demo-go-app-service
   ```

## Configuration

### Essential Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `cluster_name` | Name of the GKE cluster | `"autopilot-cluster"` |
| `region` | GCP region for deployment | `""` (uses gcloud config) |
| `project_id` | GCP project ID | `""` (uses gcloud config) |
| `environment` | Environment label | `"dev"` |
| `deletion_protection` | Enable deletion protection | `false` |

### Customization Example

Create a `terraform.tfvars` file:

```hcl
cluster_name = "my-autopilot-cluster"
environment  = "production"
region       = "us-central1"
```

## Cost Optimization Features

- **Autopilot Mode**: Pay only for running workloads, not idle nodes
- **Minimal Logging**: Only system components logging enabled by default
- **Efficient Monitoring**: Basic monitoring configuration to reduce costs
- **Regional Deployment**: Required for Autopilot, provides high availability

## Security Features

- **Workload Identity**: Secure service-to-service authentication
- **Latest Kubernetes**: STABLE release channel for security updates
- **Resource Labels**: Proper tagging for governance and cost tracking

## Maintenance

- **Automatic Updates**: Managed by GKE Autopilot
- **Maintenance Window**: Configured for off-hours (2-6 AM UTC)
- **No Node Management**: Autopilot handles all node operations

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Support

This is a simplified, production-ready configuration suitable for:
- Development environments
- Small to medium production workloads
- Teams wanting minimal operational overhead
- Cost-conscious deployments

For advanced features like private clusters, custom networking, or enterprise security, consider extending the module configuration.