package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestPostgresqlFlexibleServerFullIntegration validates a complete deployment.
func TestPostgresqlFlexibleServerFullIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/complete")
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

		resourceName := terraform.Output(t, terraformOptions, "postgresql_flexible_server_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		publicAccess := OutputBool(t, terraformOptions, "public_network_access_enabled")

		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.True(t, publicAccess)

		helper := NewPostgresqlFlexibleServerHelper(t)
		server := helper.GetServer(t, resourceGroupName, resourceName)
		ValidateServerTags(t, server, map[string]string{
			"Environment": "Test",
			"Example":     "Complete",
		})
	})
}

// TestPostgresqlFlexibleServerWithNetworkRules validates firewall rules fixture.
func TestPostgresqlFlexibleServerWithNetworkRules(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/network")
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
		firewallRules := terraform.OutputList(t, terraformOptions, "firewall_rule_names")
		assert.Len(t, firewallRules, 1)
	})
}

// TestPostgresqlFlexibleServerPrivateEndpointIntegration validates private networking.
func TestPostgresqlFlexibleServerPrivateEndpointIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/secure")
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
		publicAccess := OutputBool(t, terraformOptions, "public_network_access_enabled")
		assert.False(t, publicAccess)
	})
}

// TestPostgresqlFlexibleServerSecurityConfiguration validates secure fixture defaults.
func TestPostgresqlFlexibleServerSecurityConfiguration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/secure")
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

		resourceName := terraform.Output(t, terraformOptions, "postgresql_flexible_server_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		publicAccess := OutputBool(t, terraformOptions, "public_network_access_enabled")

		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.False(t, publicAccess)
	})
}

// TestPostgresqlFlexibleServerLifecycle tests basic lifecycle behavior.
func TestPostgresqlFlexibleServerLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceID := terraform.Output(t, terraformOptions, "postgresql_flexible_server_id")
	assert.NotEmpty(t, resourceID)

	terraform.Apply(t, terraformOptions)
	updatedResourceID := terraform.Output(t, terraformOptions, "postgresql_flexible_server_id")
	assert.Equal(t, resourceID, updatedResourceID)
}

// TestPostgresqlFlexibleServerCompliance performs simple compliance checks.
func TestPostgresqlFlexibleServerCompliance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/secure")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceName := terraform.Output(t, terraformOptions, "postgresql_flexible_server_name")
	publicAccess := OutputBool(t, terraformOptions, "public_network_access_enabled")

	assert.NotEmpty(t, resourceName)
	assert.False(t, publicAccess)
}
