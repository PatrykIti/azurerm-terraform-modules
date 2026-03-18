package test

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic azuredevops_group creation
func TestBasicAzuredevopsGroup(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer test_structure.RunTestStage(t, "cleanup", func() {
		if _, err := os.Stat(filepath.Join(testFolder, ".test-data", "TerraformOptions.json")); err == nil {
			terraform.Destroy(t, test_structure.LoadTerraformOptions(t, testFolder))
			return
		}
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		groupID := terraform.Output(t, terraformOptions, "group_id")
		groupDescriptor := terraform.Output(t, terraformOptions, "group_descriptor")

		assert.NotEmpty(t, groupID)
		assert.NotEmpty(t, groupDescriptor)
	})
}

// Test complete azuredevops_group with memberships
func TestCompleteAzuredevopsGroup(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer test_structure.RunTestStage(t, "cleanup", func() {
		if _, err := os.Stat(filepath.Join(testFolder, ".test-data", "TerraformOptions.json")); err == nil {
			terraform.Destroy(t, test_structure.LoadTerraformOptions(t, testFolder))
			return
		}
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		groupID := terraform.Output(t, terraformOptions, "group_id")
		groupMemberships := terraform.OutputMap(t, terraformOptions, "group_membership_ids")

		assert.NotEmpty(t, groupID)
		assert.NotEmpty(t, groupMemberships)
		assert.Contains(t, groupMemberships, "platform-membership")

	})
}

// Test secure azuredevops_group configuration
func TestSecureAzuredevopsGroup(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer test_structure.RunTestStage(t, "cleanup", func() {
		if _, err := os.Stat(filepath.Join(testFolder, ".test-data", "TerraformOptions.json")); err == nil {
			terraform.Destroy(t, test_structure.LoadTerraformOptions(t, testFolder))
			return
		}
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		groupID := terraform.Output(t, terraformOptions, "group_id")
		groupMemberships := terraform.OutputMap(t, terraformOptions, "group_membership_ids")

		assert.NotEmpty(t, groupID)
		assert.NotEmpty(t, groupMemberships)
		assert.Contains(t, groupMemberships, "security-membership")
	})
}

// Validate group membership selector rules
func TestAzuredevopsGroupValidationRules(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/negative")
	terraformOptions := getTerraformOptions(t, testFolder)

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "group_memberships.key must be a non-empty string.")
}

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	t.Helper()

	uniqueID := random.UniqueId()

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"group_name_prefix": fmt.Sprintf("ado-group-%s", uniqueID),
		},
		NoColor: true,
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
