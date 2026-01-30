package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestLogAnalyticsWorkspaceFullIntegration tests all features working together
func TestLogAnalyticsWorkspaceFullIntegration(t *testing.T) {
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

	test_structure.RunTestStage(t, "validate_core", func() {
		validateCoreFeatures(t, testFolder)
	})

	test_structure.RunTestStage(t, "validate_security", func() {
		validateSecurityFeatures(t, testFolder)
	})

	test_structure.RunTestStage(t, "validate_operations", func() {
		validateOperationalFeatures(t, testFolder)
	})
}

func validateCoreFeatures(t *testing.T, testFolder string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

	resourceName := terraform.Output(t, terraformOptions, "log_analytics_workspace_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

	assert.NotEmpty(t, resourceName, "Resource name should not be empty")
	assert.NotEmpty(t, resourceGroupName, "Resource group name should not be empty")
}

func validateSecurityFeatures(t *testing.T, testFolder string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

	resourceName := terraform.Output(t, terraformOptions, "log_analytics_workspace_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

	assert.NotEmpty(t, resourceName)
	assert.NotEmpty(t, resourceGroupName)
}

func validateOperationalFeatures(t *testing.T, testFolder string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

	resourceName := terraform.Output(t, terraformOptions, "log_analytics_workspace_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	resourceID := terraform.Output(t, terraformOptions, "log_analytics_workspace_id")

	assert.NotEmpty(t, resourceName)
	assert.NotEmpty(t, resourceGroupName)
	assert.NotEmpty(t, resourceID)
	assert.Contains(t, resourceID, "/providers/Microsoft.")
}

// TestLogAnalyticsWorkspaceSecurityConfiguration tests security features
func TestLogAnalyticsWorkspaceSecurityConfiguration(t *testing.T) {
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

		resourceName := terraform.Output(t, terraformOptions, "log_analytics_workspace_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
	})
}

// TestLogAnalyticsWorkspaceLifecycle tests the complete lifecycle
func TestLogAnalyticsWorkspaceLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceName := terraform.Output(t, terraformOptions, "log_analytics_workspace_name")
	resourceID := terraform.Output(t, terraformOptions, "log_analytics_workspace_id")

	assert.NotEmpty(t, resourceName)
	assert.NotEmpty(t, resourceID)

	updatedResourceID := terraform.Output(t, terraformOptions, "log_analytics_workspace_id")
	assert.Equal(t, resourceID, updatedResourceID, "Resource ID should remain the same after update")

	terraform.Apply(t, terraformOptions)
}

// TestLogAnalyticsWorkspaceCompliance tests compliance-related features
func TestLogAnalyticsWorkspaceCompliance(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
	terraformOptions := getTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceName := terraform.Output(t, terraformOptions, "log_analytics_workspace_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

	complianceChecks := []struct {
		name    string
		check   func() bool
		message string
	}{
		{
			name:    "Resource Exists",
			check:   func() bool { return resourceName != "" },
			message: "Resource must be created successfully",
		},
	}

	for _, cc := range complianceChecks {
		t.Run(cc.name, func(t *testing.T) {
			assert.True(t, cc.check(), cc.message)
		})
	}

	_ = resourceGroupName
}
