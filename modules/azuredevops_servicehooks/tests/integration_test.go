package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestAzuredevopsServicehooksFullIntegration performs a full apply on the complete fixture.
func TestAzuredevopsServicehooksFullIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/complete")
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

		webhookID := terraform.Output(t, terraformOptions, "webhook_id")
		storageQueueHookID := terraform.Output(t, terraformOptions, "storage_queue_hook_id")
		permissionIDs := terraform.OutputMap(t, terraformOptions, "servicehook_permission_ids")

		assert.NotEmpty(t, webhookID)
		assert.NotEmpty(t, storageQueueHookID)
		assert.NotEmpty(t, permissionIDs)
	})
}
