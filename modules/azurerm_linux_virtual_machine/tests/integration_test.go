package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestLinuxVirtualMachineCompleteIntegration validates the complete fixture.
func TestLinuxVirtualMachineCompleteIntegration(t *testing.T) {
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

		resourceID := terraform.Output(t, terraformOptions, "linux_virtual_machine_id")
		resourceName := terraform.Output(t, terraformOptions, "linux_virtual_machine_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		extensions := terraform.OutputMapOfObjects(t, terraformOptions, "extensions")
		diagnosticSkipped := terraform.OutputListOfObjects(t, terraformOptions, "diagnostic_settings_skipped")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.GreaterOrEqual(t, len(extensions), 1)
		assert.Len(t, diagnosticSkipped, 0)
	})
}

// TestLinuxVirtualMachineLifecycle validates basic lifecycle behavior.
func TestLinuxVirtualMachineLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	resourceID := terraform.Output(t, terraformOptions, "linux_virtual_machine_id")
	assert.NotEmpty(t, resourceID)

	terraform.Apply(t, terraformOptions)
	updatedResourceID := terraform.Output(t, terraformOptions, "linux_virtual_machine_id")
	assert.Equal(t, resourceID, updatedResourceID)
}
