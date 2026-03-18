package test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestAzuredevopsVariableGroupsFullIntegration performs a full apply on the complete fixture.
func TestAzuredevopsVariableGroupsFullIntegration(t *testing.T) {
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

		variableGroupID := terraform.Output(t, terraformOptions, "variable_group_id")

		assert.NotEmpty(t, variableGroupID)

		stateList := terraform.RunTerraformCommand(t, terraformOptions, "state", "list")
		assert.Contains(t, stateList, "module.azuredevops_variable_groups.azuredevops_variable_group_permissions.variable_group_permissions[\"readers\"]")
	})
}
