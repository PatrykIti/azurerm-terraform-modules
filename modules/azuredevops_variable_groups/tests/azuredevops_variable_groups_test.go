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

// Test basic azuredevops_variable_groups creation
func TestBasicAzuredevopsVariableGroups(t *testing.T) {
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

		variableGroupID := terraform.Output(t, terraformOptions, "variable_group_id")

		assert.NotEmpty(t, variableGroupID)
	})
}

// Test complete azuredevops_variable_groups configuration
func TestCompleteAzuredevopsVariableGroups(t *testing.T) {
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

		variableGroupID := terraform.Output(t, terraformOptions, "variable_group_id")

		assert.NotEmpty(t, variableGroupID)
	})
}

// Test secure azuredevops_variable_groups configuration
func TestSecureAzuredevopsVariableGroups(t *testing.T) {
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

		variableGroupID := terraform.Output(t, terraformOptions, "variable_group_id")

		assert.NotEmpty(t, variableGroupID)
	})
}

// Negative test cases for validation rules
func TestAzuredevopsVariableGroupsValidationRules(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/negative")
	terraformOptions := &terraform.Options{
		TerraformDir: testFolder,
		Vars: map[string]interface{}{
			"project_id": getProjectID(t),
		},
		NoColor:      true,
	}

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "variables must set exactly one of value or secret_value")
}

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	t.Helper()

	uniqueID := random.UniqueId()

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"project_id":        getProjectID(t),
			"group_name_prefix": fmt.Sprintf("ado-vg-%s", uniqueID),
		},
		NoColor: true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":         "Timeout error - retrying",
			".*TooManyRequests.*": "Too many requests - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
