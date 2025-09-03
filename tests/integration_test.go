package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"cluster_name": "test-cluster",
			"environment":  "test",
		},
	}

	// Validate the Terraform syntax
	terraform.Validate(t, terraformOptions)
}

func TestModuleValidation(t *testing.T) {
	t.Parallel()

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

			// Initialize and plan (without applying)
			terraform.InitAndPlan(t, terraformOptions)
		})
	}
}