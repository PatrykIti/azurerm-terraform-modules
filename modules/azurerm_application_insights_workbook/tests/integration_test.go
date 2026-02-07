package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestApplicationInsightsWorkbookFullIntegration validates a complete deployment.
func TestApplicationInsightsWorkbookFullIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		resourceID := terraform.Output(t, terraformOptions, "application_insights_workbook_id")
		resourceName := terraform.Output(t, terraformOptions, "application_insights_workbook_name")
		identityType := terraform.Output(t, terraformOptions, "identity_type")
		workbookStorageContainerID := terraform.Output(t, terraformOptions, "workbook_storage_container_id")
		expectedStorageContainerID := terraform.Output(t, terraformOptions, "expected_storage_container_id")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.Equal(t, "SystemAssigned", identityType)
		assert.NotEmpty(t, workbookStorageContainerID)
		assert.Equal(t, expectedStorageContainerID, workbookStorageContainerID)
	})
}

// TestApplicationInsightsWorkbookLifecycle validates basic lifecycle behavior.
func TestApplicationInsightsWorkbookLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceID := terraform.Output(t, terraformOptions, "application_insights_workbook_id")
	assert.NotEmpty(t, resourceID)

	terraform.Apply(t, terraformOptions)
	updatedResourceID := terraform.Output(t, terraformOptions, "application_insights_workbook_id")
	assert.Equal(t, resourceID, updatedResourceID)
}
