package test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestAzuredevopsTeamFullIntegration performs a full apply on the complete fixture.
func TestAzuredevopsTeamFullIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

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
