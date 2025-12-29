package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic azuredevops_environments creation
func TestBasicAzuredevopsEnvironments(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/basic")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		environmentID := terraform.Output(t, terraformOptions, "environment_id")

		assert.NotEmpty(t, environmentID)
	})
}

// Test complete azuredevops_environments configuration
func TestCompleteAzuredevopsEnvironments(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/complete")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		environmentID := terraform.Output(t, terraformOptions, "environment_id")
		kubernetesResourceIDs := terraform.OutputMap(t, terraformOptions, "kubernetes_resource_ids")
		approvalCheckIDs := terraform.OutputMap(t, terraformOptions, "approval_check_ids")

		assert.NotEmpty(t, environmentID)
		assert.NotEmpty(t, kubernetesResourceIDs)
		assert.NotEmpty(t, approvalCheckIDs)
		assert.Contains(t, approvalCheckIDs, "integration-approval")
		assert.NotEmpty(t, approvalCheckIDs["integration-approval"])
	})
}

// Test secure azuredevops_environments configuration
func TestSecureAzuredevopsEnvironments(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/secure")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		environmentID := terraform.Output(t, terraformOptions, "environment_id")

		assert.NotEmpty(t, environmentID)
	})
}

// Negative test cases for validation rules
func TestAzuredevopsEnvironmentsValidationRules(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/negative")
	terraformOptions := &terraform.Options{
		TerraformDir: testFolder,
		NoColor:      true,
		Upgrade: true,
	}

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "check_approvals.target_resource_type must be one of")
}

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	t.Helper()

	uniqueID := random.UniqueId()

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"project_id":       getProjectID(t),
			"environment_name": fmt.Sprintf("ado-env-%s", uniqueID),
		},
		NoColor: true,
		Upgrade: true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":         "Timeout error - retrying",
			".*TooManyRequests.*": "Too many requests - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
