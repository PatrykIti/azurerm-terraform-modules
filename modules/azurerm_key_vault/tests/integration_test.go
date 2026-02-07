package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestKeyVaultCompleteIntegration validates the complete fixture.
func TestKeyVaultCompleteIntegration(t *testing.T) {
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

		resourceID := terraform.Output(t, terraformOptions, "key_vault_id")
		resourceName := terraform.Output(t, terraformOptions, "key_vault_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		keys := terraform.OutputMapOfObjects(t, terraformOptions, "keys")
		secrets := terraform.OutputMapOfObjects(t, terraformOptions, "secrets")
		certificates := terraform.OutputMapOfObjects(t, terraformOptions, "certificates")
		diagnosticSkipped := terraform.OutputListOfObjects(t, terraformOptions, "diagnostic_settings_skipped")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.GreaterOrEqual(t, len(keys), 1)
		assert.GreaterOrEqual(t, len(secrets), 1)
		assert.GreaterOrEqual(t, len(certificates), 1)
		assert.Len(t, diagnosticSkipped, 0)
	})
}

// TestKeyVaultLifecycle validates basic lifecycle behavior.
func TestKeyVaultLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	resourceID := terraform.Output(t, terraformOptions, "key_vault_id")
	assert.NotEmpty(t, resourceID)

	terraform.Apply(t, terraformOptions)
	updatedResourceID := terraform.Output(t, terraformOptions, "key_vault_id")
	assert.Equal(t, resourceID, updatedResourceID)
}
