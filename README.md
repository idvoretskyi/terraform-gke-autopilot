# Terraform GKE Autopilot Cluster

A Terraform configuration for deploying Google Kubernetes Engine (GKE) Autopilot clusters with cost optimization and security best practices, plus a sample Go web application.

## Features

- **GKE Autopilot**: Fully managed Kubernetes with automatic scaling
- **Dedicated Networking**: Provisions a VPC, subnet, and configurable CIDR ranges
- **Cost-Optimized**: Minimal logging/monitoring components and efficient resource usage
- **Workload Identity**: Secure, keyless access to Google APIs
- **Deletion Protection**: Enabled by default to prevent accidental cluster deletion
- **Sample Application**: Includes a Go web app with graceful shutdown and health checks

## Repository Structure

```
.
├── main.tf                    # Root Terraform configuration
├── variables.tf               # Input variables with defaults and validations
├── outputs.tf                 # Cluster outputs
├── modules/
│   └── gke-autopilot/        # GKE Autopilot reusable module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── app/                      # Sample Go web application
│   ├── main.go
│   ├── main_test.go
│   ├── Dockerfile
│   └── README.md
├── k8s/                      # Kubernetes manifests
│   └── deployment.yaml
└── tests/
    └── unit_test.sh          # Terraform and Go unit tests
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

2. **Configure your GCP project (optional — uses gcloud config if omitted):**
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
   $(terraform output -raw kubectl_config_command)
   ```

### Deploy Sample Application

1. **Build and push the container image:**
   ```bash
   cd app
   gcloud builds submit --tag gcr.io/$(gcloud config get-value project)/demo-go-app:latest .
   ```

2. **Update the image reference in the manifest:**
   ```bash
   sed -i "s|<PROJECT_ID>|$(gcloud config get-value project)|g" k8s/deployment.yaml
   ```

3. **Deploy to Kubernetes:**
   ```bash
   kubectl apply -f k8s/deployment.yaml
   kubectl get service demo-go-app-service
   ```

## Configuration

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `cluster_name` | Name of the GKE cluster | `"autopilot-cluster"` |
| `region` | GCP region for deployment | `""` (uses gcloud config) |
| `project_id` | GCP project ID | `""` (uses gcloud config) |
| `environment` | Environment label (dev/staging/prod) | `"dev"` |
| `cost_center` | Cost center for billing | `"engineering"` |
| `release_channel` | GKE release channel (RAPID/REGULAR/STABLE) | `"RAPID"` |
| `deletion_protection` | Enable deletion protection | `true` |
| `subnet_cidr` | Primary VPC subnet CIDR | `"10.0.0.0/16"` |
| `pods_cidr` | Pod secondary range CIDR | `"10.1.0.0/16"` |
| `services_cidr` | Services secondary range CIDR | `"10.2.0.0/16"` |

### Example `terraform.tfvars`

```hcl
cluster_name        = "my-autopilot-cluster"
environment         = "prod"
region              = "us-central1"
project_id          = "my-gcp-project"
release_channel     = "REGULAR"
deletion_protection = true
```

## Cost Optimization

- **Autopilot Mode**: Pay only for running workloads, not idle nodes
- **Minimal Logging**: Only system components logging enabled by default
- **Efficient Monitoring**: Basic monitoring to reduce costs
- **Regional Deployment**: Required for Autopilot; provides high availability

## Security

- **Workload Identity**: Secure service-to-service authentication without key files
- **RAPID Release Channel**: Access to the latest Kubernetes patches quickly
- **Deletion Protection**: Enabled by default to prevent accidental cluster removal
- **Resource Labels**: Proper tagging for governance and cost tracking

## Cleanup

```bash
# Disable deletion protection first if enabled
terraform apply -var="deletion_protection=false"
terraform destroy
```
