package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic azuredevops_extension creation
func TestBasicAzuredevopsExtension(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_extension/tests/fixtures/basic")
	vars := getExtensionVarsFromEnv()
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(testFolder, vars))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(testFolder, vars)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		extensionID := terraform.Output(t, terraformOptions, "extension_id")

		assert.NotEmpty(t, extensionID)
	})
}

// Test complete azuredevops_extension with multiple extensions
func TestCompleteAzuredevopsExtension(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_extension/tests/fixtures/complete")
	vars := map[string]interface{}{
		"extensions": getExtensionsFromEnv(),
	}
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(testFolder, vars))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(testFolder, vars)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		extensionIDs := terraform.OutputMap(t, terraformOptions, "extension_ids")
		expectedCount := len(getExtensionsFromEnv())

		assert.GreaterOrEqual(t, len(extensionIDs), expectedCount)
	})
}

// Test secure azuredevops_extension configuration
func TestSecureAzuredevopsExtension(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_extension/tests/fixtures/secure")
	vars := map[string]interface{}{
		"approved_extensions": getExtensionsFromEnv(),
	}
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(testFolder, vars))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(testFolder, vars)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		extensionIDs := terraform.OutputMap(t, terraformOptions, "extension_ids")

		assert.NotEmpty(t, extensionIDs)
	})
}

// Negative test cases for validation rules
func TestAzuredevopsExtensionValidationRules(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_extension/tests/fixtures/negative")
	terraformOptions := &terraform.Options{
		TerraformDir: testFolder,
		NoColor:      true,
	}

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "publisher_id must be a non-empty string")
}

// Helper function to get terraform options
func getTerraformOptions(terraformDir string, vars map[string]interface{}) *terraform.Options {
	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars:         vars,
		NoColor: true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":         "Timeout error - retrying",
			".*TooManyRequests.*": "Too many requests - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
