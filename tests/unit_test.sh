#!/bin/bash

# Unit tests for Terraform GKE Autopilot configuration
# This script validates Terraform configurations without deploying resources

set -e

echo "=== Terraform GKE Autopilot Unit Tests ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Test 1: Terraform format check
test_terraform_fmt() {
    print_status "Testing Terraform formatting..."
    if terraform fmt -check -recursive ../; then
        print_status "✓ Terraform formatting is correct"
    else
        print_error "✗ Terraform formatting issues found"
        return 1
    fi
}

# Test 2: Terraform validation
test_terraform_validate() {
    print_status "Testing Terraform validation..."
    
    # Test root module
    cd ../
    terraform init -backend=false > /dev/null 2>&1
    if terraform validate; then
        print_status "✓ Root module validation passed"
    else
        print_error "✗ Root module validation failed"
        return 1
    fi
    
    # Test gke-autopilot module
    cd modules/gke-autopilot
    terraform init -backend=false > /dev/null 2>&1
    if terraform validate; then
        print_status "✓ GKE Autopilot module validation passed"
    else
        print_error "✗ GKE Autopilot module validation failed"
        return 1
    fi
    
    cd ../../tests
}

# Test 3: Check cost optimization configurations
test_cost_optimization() {
    print_status "Testing cost optimization configurations..."
    
    # Check if cost-optimized defaults are set in variables
    if grep -q "SYSTEM_COMPONENTS" ../variables.tf; then
        print_status "✓ Cost-optimized logging components set"
    else
        print_warning "⚠ Check logging components configuration"
    fi
    
    if grep -q "enable_cluster_autoscaling.*true" ../variables.tf; then
        print_status "✓ Cluster autoscaling enabled by default"
    else
        print_warning "⚠ Cluster autoscaling should be enabled for cost optimization"
    fi
    
    if grep -q "enable_cost_management.*true" ../variables.tf; then
        print_status "✓ Cost management enabled by default"
    else
        print_warning "⚠ Cost management should be enabled"
    fi
}

# Test 4: Security configuration validation
test_security_config() {
    print_status "Testing security configurations..."
    
    # Check if workload identity is configured
    if grep -q "workload_identity_config" ../modules/gke-autopilot/main.tf; then
        print_status "✓ Workload Identity is configured"
    else
        print_error "✗ Workload Identity must be configured"
        return 1
    fi
    
    # Check if binary authorization is available
    if grep -q "binary_authorization" ../modules/gke-autopilot/main.tf; then
        print_status "✓ Binary Authorization option available"
    else
        print_warning "⚠ Consider adding Binary Authorization"
    fi
}

# Test 5: Environment-specific configurations
test_environment_configs() {
    print_status "Testing environment-specific configurations..."
    
    for env in dev prod; do
        if [[ -f "../environments/${env}/terraform.tfvars" ]]; then
            print_status "✓ Environment config found: $env"
            
            # Validate environment-specific settings
            if grep -q "environment.*=.*\"${env}\"" "../environments/${env}/terraform.tfvars"; then
                print_status "✓ Environment variable correctly set in $env"
            else
                print_error "✗ Environment variable not properly set in $env"
                return 1
            fi
        else
            print_error "✗ Missing environment config: $env"
            return 1
        fi
    done
}

# Test 6: Check for sensitive data in Terraform files
test_sensitive_data() {
    print_status "Checking for sensitive data..."
    
    # Check for hardcoded credentials or sensitive info in Terraform files only
    if find .. -name "*.tf" -o -name "*.tfvars" | xargs grep -l -i "password\|secret\|key\|token" 2>/dev/null | head -5; then
        print_warning "⚠ Potential sensitive data found in Terraform files - review carefully"
    else
        print_status "✓ No obvious sensitive data found in Terraform files"
    fi
    
    # Check .gitignore
    if grep -q "*.tfvars" ../.gitignore; then
        print_status "✓ tfvars files are properly gitignored"
    else
        print_error "✗ tfvars files should be in .gitignore"
        return 1
    fi
}

# Test 7: GitHub Actions workflow validation
test_github_actions() {
    print_status "Testing GitHub Actions workflows..."
    
    if [[ -f "../.github/workflows/terraform-ci.yml" ]]; then
        print_status "✓ CI workflow found"
    else
        print_error "✗ Missing CI workflow"
        return 1
    fi
    
    if [[ -f "../.github/dependabot.yml" ]]; then
        print_status "✓ Dependabot configuration found"
    else
        print_error "✗ Missing Dependabot configuration"
        return 1
    fi
}

# Test 8: Dynamic gcloud configuration
test_dynamic_gcloud_config() {
    print_status "Testing dynamic gcloud configuration..."
    
    # Check if external provider is configured
    if grep -q "hashicorp/external" ../modules/gke-autopilot/versions.tf; then
        print_status "✓ External provider configured for dynamic config"
    else
        print_error "✗ External provider missing for dynamic config"
        return 1
    fi
    
    # Check if external data source exists
    if grep -q "data \"external\" \"gcloud_config\"" ../modules/gke-autopilot/main.tf; then
        print_status "✓ External data source for gcloud config found"
    else
        print_error "✗ External data source for gcloud config missing"
        return 1
    fi
    
    # Test the gcloud config script
    if command -v gcloud >/dev/null 2>&1; then
        if command -v jq >/dev/null 2>&1; then
            local config_output
            config_output=$(bash -c 'set -e
                project=$(gcloud config get-value project 2>/dev/null || echo "")
                region=$(gcloud config get-value compute/region 2>/dev/null || echo "")
                zone=$(gcloud config get-value compute/zone 2>/dev/null || echo "")
                account=$(gcloud config get-value account 2>/dev/null || echo "")
                
                if [ -z "$region" ] && [ -n "$zone" ]; then
                    region=$(echo "$zone" | sed "s/-[a-z]$/")
                fi
                
                jq -n \
                    --arg project "$project" \
                    --arg region "$region" \
                    --arg zone "$zone" \
                    --arg account "$account" \
                    "{project: \$project, region: \$region, zone: \$zone, account: \$account}"
            ' 2>/dev/null)
            
            if [[ -n "$config_output" ]]; then
                print_status "✓ Dynamic gcloud config script works"
            else
                print_warning "⚠ Dynamic gcloud config script failed (this is OK if gcloud/jq not configured)"
            fi
        else
            print_warning "⚠ jq not available for gcloud config testing"
        fi
    else
        print_warning "⚠ gcloud CLI not available for testing"
    fi
}

# Run all tests
main() {
    print_status "Starting Terraform GKE Autopilot unit tests..."
    
    local failed_tests=0
    
    test_terraform_fmt || ((failed_tests++))
    test_terraform_validate || ((failed_tests++))
    test_cost_optimization
    test_security_config || ((failed_tests++))
    test_environment_configs || ((failed_tests++))
    test_sensitive_data || ((failed_tests++))
    test_github_actions || ((failed_tests++))
    test_dynamic_gcloud_config || ((failed_tests++))
    
    echo ""
    if [[ $failed_tests -eq 0 ]]; then
        print_status "=== All tests passed! ==="
        exit 0
    else
        print_error "=== $failed_tests test(s) failed ==="
        exit 1
    fi
}

# Make sure we're in the tests directory
cd "$(dirname "$0")"

# Run the tests
main