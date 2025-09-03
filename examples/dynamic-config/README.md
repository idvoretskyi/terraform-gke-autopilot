# Dynamic gcloud Configuration Example

This example demonstrates how the GKE Autopilot module automatically detects and uses your local gcloud configuration.

## Prerequisites

1. Install and authenticate gcloud CLI:
   ```bash
   # Install gcloud CLI
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL
   
   # Authenticate
   gcloud auth login
   gcloud auth application-default login
   ```

2. Set your default project and region:
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   gcloud config set compute/region YOUR_PREFERRED_REGION
   ```

## Usage

Deploy the cluster with automatic configuration detection:

```bash
terraform init
terraform plan    # Shows what project/region will be used
terraform apply
```

## Configuration Hierarchy

The module uses this priority order for configuration:

1. **Explicit variables** (if provided in terraform.tfvars or -var)
2. **gcloud CLI configuration** (from `gcloud config get-value`)
3. **Terraform google_client_config** (from current auth context)
4. **Sensible defaults** (us-central1 for region)

## Viewing Detected Configuration

After applying, you can see what configuration was automatically detected:

```bash
# See all detected gcloud values
terraform output detected_gcloud_config

# See the source of each configuration value
terraform output config_source_info

# Example output:
# detected_gcloud_config = {
#   "account" = "user@example.com"
#   "project_id" = "my-gcp-project"
#   "region" = "us-west2"
#   "zone" = "us-west2-a"
# }
#
# config_source_info = {
#   "project_id_source" = "gcloud"
#   "region_source" = "gcloud"
# }
```

## Benefits

- **Zero configuration**: Works out of the box with your gcloud setup
- **Flexible**: Can override any value with variables when needed
- **Transparent**: Shows exactly what configuration is being used
- **Consistent**: Uses the same project/region as your other gcloud commands