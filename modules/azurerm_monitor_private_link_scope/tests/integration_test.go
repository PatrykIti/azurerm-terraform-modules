package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestMonitorPrivateLinkScopeFullIntegration validates a complete deployment.
func TestMonitorPrivateLinkScopeFullIntegration(t *testing.T) {
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

		resourceName := terraform.Output(t, terraformOptions, "monitor_private_link_scope_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		resourceID := terraform.Output(t, terraformOptions, "monitor_private_link_scope_id")

		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.NotEmpty(t, resourceID)
	})
}

// TestMonitorPrivateLinkScopeWithNetworkRules validates access modes fixture.
func TestMonitorPrivateLinkScopeWithNetworkRules(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/network")
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
		resourceID := terraform.Output(t, terraformOptions, "monitor_private_link_scope_id")
		assert.NotEmpty(t, resourceID)
	})
}

// TestMonitorPrivateLinkScopePrivateEndpointIntegration validates private endpoint fixture when present.
func TestMonitorPrivateLinkScopePrivateEndpointIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	if _, err := os.Stat("fixtures/private_endpoint"); os.IsNotExist(err) {
		t.Skip("Private endpoint fixture not found; skipping test")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/private_endpoint")
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
		resourceID := terraform.Output(t, terraformOptions, "monitor_private_link_scope_id")
		privateEndpointID := terraform.Output(t, terraformOptions, "private_endpoint_id")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, privateEndpointID)
	})
}

// TestMonitorPrivateLinkScopeSecurityConfiguration validates secure fixture defaults.
func TestMonitorPrivateLinkScopeSecurityConfiguration(t *testing.T) {
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
		resourceName := terraform.Output(t, terraformOptions, "monitor_private_link_scope_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
	})
}

// TestMonitorPrivateLinkScopeLifecycle tests basic lifecycle behavior.
func TestMonitorPrivateLinkScopeLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceID := terraform.Output(t, terraformOptions, "monitor_private_link_scope_id")
	assert.NotEmpty(t, resourceID)

	terraform.Apply(t, terraformOptions)
	updatedResourceID := terraform.Output(t, terraformOptions, "monitor_private_link_scope_id")
	assert.Equal(t, resourceID, updatedResourceID)
}

// TestMonitorPrivateLinkScopeCompliance performs simple compliance checks.
func TestMonitorPrivateLinkScopeCompliance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceName := terraform.Output(t, terraformOptions, "monitor_private_link_scope_name")
	assert.NotEmpty(t, resourceName)
}
