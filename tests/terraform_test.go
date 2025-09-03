package test

import (
	"testing"
	"strings"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestGKEAutopilotCluster(t *testing.T) {
	t.Parallel()

	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../",
		
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"cluster_name": "test-autopilot-cluster",
			"environment":  "test",
			"cost_center":  "testing",
		},
		
		// Variables to pass to our Terraform code using TF_VAR_xxx environment variables
		EnvVars: map[string]string{
			"TF_VAR_project_id": "", // Use default gcloud project
		},
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables and check they have the expected values.
	clusterName := terraform.Output(t, terraformOptions, "kubernetes_cluster_name")
	assert.Equal(t, "test-autopilot-cluster", clusterName)

	region := terraform.Output(t, terraformOptions, "region")
	assert.NotEmpty(t, region)

	projectID := terraform.Output(t, terraformOptions, "project_id")
	assert.NotEmpty(t, projectID)

	kubectlCommand := terraform.Output(t, terraformOptions, "kubectl_config_command")
	assert.Contains(t, kubectlCommand, "gcloud container clusters get-credentials")
	assert.Contains(t, kubectlCommand, "test-autopilot-cluster")
}

func TestGKEAutopilotCostOptimization(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"cluster_name":               "cost-test-cluster",
			"environment":                "test",
			"enable_cluster_autoscaling": true,
			"enable_cost_management":     true,
			"max_cpu_cores":             10,
			"max_memory_gb":             40,
			"logging_components":        []string{"SYSTEM_COMPONENTS"},
			"monitoring_components":     []string{"SYSTEM_COMPONENTS"},
			"enable_managed_prometheus": false,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify cost optimization settings are applied
	clusterName := terraform.Output(t, terraformOptions, "kubernetes_cluster_name")
	assert.Equal(t, "cost-test-cluster", clusterName)

	labels := terraform.OutputMap(t, terraformOptions, "cluster_labels")
	assert.Equal(t, "test", labels["environment"])
	assert.Equal(t, "terraform", labels["managed_by"])
}

func TestTerraformValidation(t *testing.T) {
	// Test terraform validation
	terraformOptions := &terraform.Options{
		TerraformDir: "../",
	}

	// Run terraform validate to ensure the syntax is correct
	terraform.Validate(t, terraformOptions)
}

func TestModuleValidation(t *testing.T) {
	// Test module validation
	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/gke-autopilot",
	}

	terraform.Validate(t, terraformOptions)
}

func TestEnvironmentConfigurations(t *testing.T) {
	environments := []string{"dev", "prod"}

	for _, env := range environments {
		t.Run(env, func(t *testing.T) {
			terraformOptions := &terraform.Options{
				TerraformDir: "../",
				VarFiles:     []string{"environments/" + env + "/terraform.tfvars"},
			}

			// Validate the configuration
			terraform.Validate(t, terraformOptions)

			// Plan the configuration
			plan := terraform.InitAndPlan(t, terraformOptions)
			
			// Verify the plan contains expected resources
			assert.Contains(t, plan, "google_container_cluster.autopilot_cluster")
		})
	}
}