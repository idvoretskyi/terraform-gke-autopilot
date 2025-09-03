# Terraform GKE Autopilot Cluster

This repository contains a modular Terraform configuration to deploy a cost-efficient Google Kubernetes Engine (GKE) Autopilot cluster on Google Cloud Platform.

## Features

- **Modular Design**: Organized modules for maintainability and reusability
- **Cost-Optimized**: Multiple cost optimization strategies built-in
- **Environment Support**: Separate configurations for dev/staging/prod
- **Security-First**: Configurable security features including Workload Identity, Binary Authorization
- **Comprehensive Testing**: Unit tests and integration tests included
- **GKE Autopilot**: Serverless Kubernetes with pay-per-request pricing

## Repository Structure

```
.
├── main.tf                          # Root configuration using the module
├── variables.tf                     # Root variables
├── outputs.tf                       # Root outputs
├── terraform.tfvars.example         # Example configuration
├── modules/
│   └── gke-autopilot/              # Reusable GKE Autopilot module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── environments/                    # Environment-specific configurations
│   ├── dev/terraform.tfvars
│   └── prod/terraform.tfvars
├── tests/                          # Testing suite
│   ├── terraform_test.go           # Integration tests (Terratest)
│   ├── unit_test.sh               # Unit tests
│   └── go.mod
└── Makefile                        # Common operations
```

## Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) configured and authenticated
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (v1.0.0+)
- A Google Cloud Platform account with billing enabled
- Required APIs enabled:
  - Kubernetes Engine API (`gcloud services enable container.googleapis.com`)
  - Compute Engine API (`gcloud services enable compute.googleapis.com`)

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/idvoretskyi/terraform-gke-autopilot.git
   cd terraform-gke-autopilot
   ```

2. **Authenticate with Google Cloud** (the configuration will automatically use your gcloud settings):
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   gcloud config set compute/region YOUR_PREFERRED_REGION  # optional
   ```

3. **Deploy with automatic configuration** (no tfvars needed for basic setup):
   ```bash
   make init
   make plan    # Will show what project/region will be used
   make apply
   ```

4. **Or customize with tfvars** (optional):
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars to override defaults
   make apply
   ```

5. Configure kubectl:
   ```bash
   make kubectl-config
   ```

### Dynamic Configuration

The module automatically detects and uses your gcloud configuration:

- **Project ID**: Uses `gcloud config get-value project` if no variable provided
- **Region**: Uses `gcloud config get-value compute/region` or derives from zone
- **Authentication**: Uses your current `gcloud auth` credentials

Check what configuration will be used:
```bash
terraform plan  # Shows detected values in plan output
# After apply:
terraform output gcloud_config_used  # Shows what was actually used
terraform output config_source       # Shows source of each config value
```

### Example with Dynamic Configuration

See the complete example in [`examples/dynamic-config/`](examples/dynamic-config/) which demonstrates:
- Zero-configuration deployment using gcloud settings
- Configuration source visibility
- Override capabilities

## Using with Environment Configurations

For environment-specific deployments:

```bash
# Development environment
make plan-dev
make apply-dev

# Production environment  
make plan-prod
make apply-prod
```

## Cost Optimization Features

This configuration implements multiple cost-optimization strategies:

- **GKE Autopilot**: Pay only for resources actually requested by workloads
- **Cluster Autoscaling**: Automatic scaling based on demand with configurable limits
- **Cost Management**: Built-in GKE cost allocation and tracking
- **Resource Labels**: Comprehensive labeling for cost attribution
- **Minimal Observability**: System components only by default (workloads optional)
- **STABLE Release Channel**: Predictable upgrades and fewer disruptions
- **Off-hours Maintenance**: Scheduled during low-traffic periods
- **Regional Deployment**: Uses your current gcloud region to avoid cross-region charges

### Cost Control Variables

- `max_cpu_cores`: Limit maximum CPU cores (default: 50 for root, 20 for dev, 100 for prod)
- `max_memory_gb`: Limit maximum memory (default: 200 for root, 80 for dev, 400 for prod)
- `enable_managed_prometheus`: Disable by default (adds cost)
- `logging_components`: Minimal system logging by default

## Testing

Run the test suite to validate configurations:

```bash
# Unit tests (fast, no resources created)
make test-unit

# Integration tests (slower, creates actual resources)
make test-integration

# All tests
make test-all
```

## Security Features

Configurable security options:

- **Workload Identity**: Enabled by default for keyless authentication
- **Private Clusters**: Optional private cluster configuration
- **Network Policy**: Optional network segmentation
- **Binary Authorization**: Optional container image verification

## Advanced Usage

### Custom Backend Setup

Set up GCS backend for state management:

```bash
export TF_BUCKET="${GOOGLE_CLOUD_PROJECT:-$(gcloud config get-value project)}-tf-state"
export TF_PREFIX="gke-autopilot"
make setup-backend
```

### Cost Estimation

Estimate costs before deployment (requires [Infracost](https://www.infracost.io/)):

```bash
make cost-estimate
```

### Security Scanning

Scan for security issues (requires [tfsec](https://github.com/aquasecurity/tfsec)):

```bash
make security-scan
```

### Using as a Module

You can use this as a module in other Terraform configurations:

```hcl
module "gke_cluster" {
  source = "github.com/idvoretskyi/terraform-gke-autopilot//modules/gke-autopilot"
  
  cluster_name = "my-cluster"
  environment  = "prod"
  
  # Cost optimization
  max_cpu_cores = 100
  max_memory_gb = 400
  
  # Security
  enable_private_cluster = true
  enable_network_policy  = true
}
```

## Cleanup

Destroy resources when no longer needed:

```bash
make destroy
# or for specific environments
make destroy-dev
make destroy-prod
```

## CI/CD and Automation

This repository includes comprehensive CI/CD automation:

### GitHub Actions Workflows

- **`terraform-ci.yml`**: Complete CI pipeline with validation, security scanning, unit tests, cost estimation, and integration tests
- **`terraform-plan.yml`**: Automatic Terraform planning for pull requests with environment matrix
- **`dependabot-automerge.yml`**: Auto-merge approved dependency updates
- **`release.yml`**: Automated releases when tags are pushed

### Dependabot Configuration

Automatic dependency updates for:
- Terraform providers (weekly)
- Go dependencies for tests (weekly)
- GitHub Actions (weekly)

### Testing

```bash
# Run all tests locally
make test-all

# Individual test categories
make test-unit              # Quick validation tests
make test-integration       # Terratest integration tests
make security-scan         # Security scanning (requires tfsec)
make cost-estimate          # Cost estimation (requires infracost)
```

### Repository Secrets Required

For full CI/CD functionality, configure these GitHub secrets:

- `GCP_SA_KEY`: GCP Service Account JSON key for integration tests
- `GCP_PROJECT_ID`: GCP project ID for testing
- `INFRACOST_API_KEY`: API key for cost estimation (optional)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and add tests
4. Run `make validate-all` to validate locally
5. Submit a pull request (CI will run automatically)

All PRs trigger:
- Terraform validation and formatting checks
- Security scanning with tfsec and Checkov
- Unit tests and cost estimation
- Automatic Terraform plans for both dev and prod environments

## License

MIT
