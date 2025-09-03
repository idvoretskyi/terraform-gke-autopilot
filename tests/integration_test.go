package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestCompleteIntegration tests the full integration of Terraform configuration
func TestCompleteIntegration(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"cluster_name": "integration-test-cluster",
			"environment":  "dev",
		},
	})

	// Initialize, validate, and plan (no apply for integration test)
	terraform.Init(t, terraformOptions)
	plan := terraform.Plan(t, terraformOptions)

	// Verify the plan contains expected GKE resources
	assert.Contains(t, plan, "google_container_cluster.autopilot_cluster")
	assert.Contains(t, plan, "integration-test-cluster")
}