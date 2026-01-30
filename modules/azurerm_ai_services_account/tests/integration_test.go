package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestAiServicesAccountFullIntegration exercises the complete fixture in a single run.
func TestAiServicesAccountFullIntegration(t *testing.T) {
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
		resourceID := terraform.Output(t, terraformOptions, "ai_services_account_id")
		resourceName := terraform.Output(t, terraformOptions, "ai_services_account_name")
		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
	})
}

// TestAiServicesAccountLifecycle validates idempotency on the basic fixture.
func TestAiServicesAccountLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping lifecycle test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	initialID := terraform.Output(t, terraformOptions, "ai_services_account_id")
	assert.NotEmpty(t, initialID)

	terraform.Apply(t, terraformOptions)
	updatedID := terraform.Output(t, terraformOptions, "ai_services_account_id")
	assert.Equal(t, initialID, updatedID)
}
