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

// Test basic azuredevops_pipelines creation
func TestBasicAzuredevopsRepository(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_pipelines/tests/fixtures/basic")
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

		repositoryIDs := terraform.OutputMap(t, terraformOptions, "repository_ids")

		assert.NotEmpty(t, repositoryIDs)
	})
}

// Test complete azuredevops_pipelines configuration
func TestCompleteAzuredevopsRepository(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_pipelines/tests/fixtures/complete")
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

		repositoryIDs := terraform.OutputMap(t, terraformOptions, "repository_ids")
		branchIDs := terraform.OutputMap(t, terraformOptions, "branch_ids")

		assert.NotEmpty(t, repositoryIDs)
		assert.NotEmpty(t, branchIDs)
	})
}

// Test secure azuredevops_pipelines configuration
func TestSecureAzuredevopsRepository(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_pipelines/tests/fixtures/secure")
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

		repositoryIDs := terraform.OutputMap(t, terraformOptions, "repository_ids")

		assert.NotEmpty(t, repositoryIDs)
	})
}

// Negative test cases for validation rules
func TestAzuredevopsRepositoryValidationRules(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_pipelines/tests/fixtures/negative")
	terraformOptions := &terraform.Options{
		TerraformDir: testFolder,
		NoColor:      true,
	}

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "repository_id or repository_key")
}

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	t.Helper()

	uniqueID := random.UniqueId()

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"project_id":       getProjectID(t),
			"repo_name_prefix": fmt.Sprintf("ado-repo-%s", uniqueID),
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
