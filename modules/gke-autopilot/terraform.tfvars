# Sample values for terraform validate runs in this module
# Used for standalone validation: terraform -chdir=modules/gke-autopilot validate
cluster_name          = "test-cluster"
region                = "us-central1"
project_id            = "your-gcp-project"
environment           = "dev"
cost_center           = "engineering"
release_channel       = "RAPID"
deletion_protection   = false
logging_components    = ["SYSTEM_COMPONENTS"]
monitoring_components = ["SYSTEM_COMPONENTS"]
subnet_cidr           = "10.0.0.0/16"
pods_cidr             = "10.1.0.0/16"
services_cidr         = "10.2.0.0/16"
