package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestServicePlanFullIntegration validates a complete deployment.
func TestServicePlanFullIntegration(t *testing.T) {
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

		resourceName := terraform.Output(t, terraformOptions, "service_plan_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		perSiteScalingEnabled := OutputBool(t, terraformOptions, "per_site_scaling_enabled")
		workerCount := OutputInt(t, terraformOptions, "worker_count")
		diagnosticSettingsSkippedCount := OutputInt(t, terraformOptions, "diagnostic_settings_skipped_count")

		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.True(t, perSiteScalingEnabled)
		assert.Equal(t, 1, workerCount)
		assert.Equal(t, 0, diagnosticSettingsSkippedCount)

		helper := NewServicePlanHelper(t)
		servicePlan := helper.GetServicePlan(t, resourceGroupName, resourceName)
		ValidateServicePlanTags(t, servicePlan, map[string]string{
			"Environment": "Test",
			"Example":     "Complete",
		})
	})
}

// TestServicePlanWithDiagnosticSettings validates complete fixture diagnostics.
func TestServicePlanWithDiagnosticSettings(t *testing.T) {
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
		diagnosticSettingsSkippedCount := OutputInt(t, terraformOptions, "diagnostic_settings_skipped_count")
		assert.Equal(t, 0, diagnosticSettingsSkippedCount)
	})
}

// TestServicePlanSecureConfiguration validates the secure fixture.
func TestServicePlanSecureConfiguration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
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
		resourceName := terraform.Output(t, terraformOptions, "service_plan_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		reserved := OutputBool(t, terraformOptions, "reserved")
		diagnosticSettingsSkippedCount := OutputInt(t, terraformOptions, "diagnostic_settings_skipped_count")

		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.False(t, reserved)
		assert.Equal(t, 0, diagnosticSettingsSkippedCount)
	})
}

// TestServicePlanLifecycle tests basic lifecycle behavior.
func TestServicePlanLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceID := terraform.Output(t, terraformOptions, "service_plan_id")
	assert.NotEmpty(t, resourceID)

	terraform.Apply(t, terraformOptions)
	updatedResourceID := terraform.Output(t, terraformOptions, "service_plan_id")
	assert.Equal(t, resourceID, updatedResourceID)
}

// TestServicePlanCompliance performs simple compliance checks.
func TestServicePlanCompliance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceName := terraform.Output(t, terraformOptions, "service_plan_name")
	reserved := OutputBool(t, terraformOptions, "reserved")

	assert.NotEmpty(t, resourceName)
	assert.False(t, reserved)
}
