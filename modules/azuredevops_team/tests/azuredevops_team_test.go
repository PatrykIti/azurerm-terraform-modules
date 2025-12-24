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

// Test basic azuredevops_team creation
func TestBasicAzuredevopsTeam(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_team/tests/fixtures/basic")
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

		teamIDs := terraform.OutputMap(t, terraformOptions, "team_ids")
		teamDescriptors := terraform.OutputMap(t, terraformOptions, "team_descriptors")

		assert.NotEmpty(t, teamIDs)
		assert.NotEmpty(t, teamDescriptors)
	})
}

// Test complete azuredevops_team with memberships and admins
func TestCompleteAzuredevopsTeam(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_team/tests/fixtures/complete")
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

		teamIDs := terraform.OutputMap(t, terraformOptions, "team_ids")
		teamMemberIDs := terraform.OutputMap(t, terraformOptions, "team_member_ids")

		assert.GreaterOrEqual(t, len(teamIDs), 2)
		assert.NotEmpty(t, teamMemberIDs)
	})
}

// Test secure azuredevops_team configuration
func TestSecureAzuredevopsTeam(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_team/tests/fixtures/secure")
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

		teamIDs := terraform.OutputMap(t, terraformOptions, "team_ids")
		adminIDs := terraform.OutputMap(t, terraformOptions, "team_administrator_ids")

		assert.NotEmpty(t, teamIDs)
		assert.NotEmpty(t, adminIDs)
	})
}

// Validate membership selector rules
func TestAzuredevopsTeamValidationRules(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_team/tests/fixtures/negative")
	terraformOptions := getTerraformOptions(t, testFolder)

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "team_id or team_key")
}

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	t.Helper()

	uniqueID := random.UniqueId()

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"project_id":       getProjectID(t),
			"team_name_prefix": fmt.Sprintf("ado-team-%s", uniqueID),
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
