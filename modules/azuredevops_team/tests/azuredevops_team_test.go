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

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
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

		teamID := terraform.Output(t, terraformOptions, "team_id")
		teamDescriptor := terraform.Output(t, terraformOptions, "team_descriptor")

		assert.NotEmpty(t, teamID)
		assert.NotEmpty(t, teamDescriptor)
	})
}

// Test complete azuredevops_team with memberships and admins
func TestCompleteAzuredevopsTeam(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
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

		teamMemberIDs := terraform.OutputMap(t, terraformOptions, "team_member_ids")
		teamAdministratorIDs := terraform.OutputMap(t, terraformOptions, "team_administrator_ids")
		teamID := terraform.Output(t, terraformOptions, "team_id")

		assert.NotEmpty(t, teamID)
		assert.NotEmpty(t, teamMemberIDs)
		_, ok := teamMemberIDs["team-members"]
		assert.True(t, ok)
		_, ok = teamAdministratorIDs["team-admins"]
		assert.True(t, ok)
	})
}

// Test secure azuredevops_team configuration
func TestSecureAzuredevopsTeam(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
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

		adminIDs := terraform.OutputMap(t, terraformOptions, "team_administrator_ids")
		teamID := terraform.Output(t, terraformOptions, "team_id")

		assert.NotEmpty(t, teamID)
		assert.NotEmpty(t, adminIDs)
		_, ok := adminIDs["security-admins"]
		assert.True(t, ok)
	})
}

// Validate membership selector rules
func TestAzuredevopsTeamValidationRules(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/negative")
	terraformOptions := getTerraformOptions(t, testFolder)

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "team_members entries must set key when team_id is not provided")
}

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	t.Helper()

	uniqueID := random.UniqueId()

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"project_id":    getProjectID(t),
			"random_suffix": fmt.Sprintf("ado-%s", uniqueID),
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
