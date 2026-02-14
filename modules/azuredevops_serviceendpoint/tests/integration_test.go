package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestAzuredevopsServiceendpointFullIntegration performs a full apply on the complete fixture.
func TestAzuredevopsServiceendpointFullIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

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

		primaryEndpointID := terraform.Output(t, terraformOptions, "primary_serviceendpoint_id")
		secondaryEndpointID := terraform.Output(t, terraformOptions, "secondary_serviceendpoint_id")
		primaryPermissions := terraform.OutputMap(t, terraformOptions, "primary_permissions")

		assert.NotEmpty(t, primaryEndpointID)
		assert.NotEmpty(t, secondaryEndpointID)
		assert.NotEmpty(t, primaryPermissions)
	})
}
