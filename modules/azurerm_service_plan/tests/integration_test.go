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
		zoneBalancingEnabled := OutputBool(t, terraformOptions, "zone_balancing_enabled")
		workerCount := OutputInt(t, terraformOptions, "worker_count")

		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.True(t, zoneBalancingEnabled)
		assert.Equal(t, 2, workerCount)

		helper := NewServicePlanHelper(t)
		servicePlan := helper.GetServicePlan(t, resourceGroupName, resourceName)
		ValidateServicePlanTags(t, servicePlan, map[string]string{
			"Environment": "Test",
			"Example":     "Complete",
		})
	})
}

// TestServicePlanElasticPremiumIntegration validates Elastic Premium configuration.
func TestServicePlanElasticPremiumIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/elastic")
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
		premiumPlanAutoScaleEnabled := OutputBool(t, terraformOptions, "premium_plan_auto_scale_enabled")
		maximumElasticWorkerCount := OutputInt(t, terraformOptions, "maximum_elastic_worker_count")

		assert.True(t, premiumPlanAutoScaleEnabled)
		assert.Equal(t, 20, maximumElasticWorkerCount)
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
		reserved := OutputBool(t, terraformOptions, "reserved")
		zoneBalancingEnabled := OutputBool(t, terraformOptions, "zone_balancing_enabled")

		assert.False(t, reserved)
		assert.True(t, zoneBalancingEnabled)
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

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceName := terraform.Output(t, terraformOptions, "service_plan_name")
	zoneBalancingEnabled := OutputBool(t, terraformOptions, "zone_balancing_enabled")

	assert.NotEmpty(t, resourceName)
	assert.True(t, zoneBalancingEnabled)
}
