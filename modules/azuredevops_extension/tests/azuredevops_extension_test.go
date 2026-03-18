package test

import (
	"os"
	"path/filepath"
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

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	vars := getExtensionVarsFromEnv()
	terraformOptions := getTerraformOptions(testFolder, vars)
	shouldCleanup := true
	defer test_structure.RunTestStage(t, "cleanup", func() {
		if shouldCleanup {
			if _, err := os.Stat(filepath.Join(testFolder, ".test-data", "TerraformOptions.json")); err == nil {
				terraform.Destroy(t, test_structure.LoadTerraformOptions(t, testFolder))
				return
			}
			terraform.Destroy(t, terraformOptions)
			return
		}

		t.Log("Skipping cleanup because extension existed prior to test run")
	})

	test_structure.RunTestStage(t, "deploy", func() {
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		created, err := applyWithImportIfInstalled(t, terraformOptions, buildBasicImportTargets(t, vars))
		require.NoError(t, err)
		if !created {
			shouldCleanup = false
		}
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

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
	extensions := getExtensionsFromEnv()
	vars := map[string]interface{}{
		"extensions": extensions,
	}
	terraformOptions := getTerraformOptions(testFolder, vars)
	shouldCleanup := true
	defer test_structure.RunTestStage(t, "cleanup", func() {
		if shouldCleanup {
			if _, err := os.Stat(filepath.Join(testFolder, ".test-data", "TerraformOptions.json")); err == nil {
				terraform.Destroy(t, test_structure.LoadTerraformOptions(t, testFolder))
				return
			}
			terraform.Destroy(t, terraformOptions)
			return
		}

		t.Log("Skipping cleanup because extension existed prior to test run")
	})

	test_structure.RunTestStage(t, "deploy", func() {
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		created, err := applyWithImportIfInstalled(t, terraformOptions, buildForEachImportTargets(t, extensions))
		require.NoError(t, err)
		if !created {
			shouldCleanup = false
		}
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

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
	extensions := getExtensionsFromEnv()
	vars := map[string]interface{}{
		"approved_extensions": extensions,
	}
	terraformOptions := getTerraformOptions(testFolder, vars)
	shouldCleanup := true
	defer test_structure.RunTestStage(t, "cleanup", func() {
		if shouldCleanup {
			if _, err := os.Stat(filepath.Join(testFolder, ".test-data", "TerraformOptions.json")); err == nil {
				terraform.Destroy(t, test_structure.LoadTerraformOptions(t, testFolder))
				return
			}
			terraform.Destroy(t, terraformOptions)
			return
		}

		t.Log("Skipping cleanup because extension existed prior to test run")
	})

	test_structure.RunTestStage(t, "deploy", func() {
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		created, err := applyWithImportIfInstalled(t, terraformOptions, buildForEachImportTargets(t, extensions))
		require.NoError(t, err)
		if !created {
			shouldCleanup = false
		}
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

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/negative")
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
		NoColor:      true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":                  "Timeout error - retrying",
			".*TooManyRequests.*":          "Too many requests - retrying",
			".*connection reset by peer.*": "Azure DevOps connection reset - retrying",
			".*invalid character '<' looking for beginning of value.*": "Azure DevOps returned HTML instead of JSON - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
