package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestAzuredevopsExtensionFullIntegration performs a full apply on the complete fixture.
func TestAzuredevopsExtensionFullIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
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

		assert.NotEmpty(t, extensionIDs)
	})
}
