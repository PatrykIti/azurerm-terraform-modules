package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestManagedRedisFullIntegration validates a complete deployment.
func TestManagedRedisFullIntegration(t *testing.T) {
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

		resourceName := OutputString(t, terraformOptions, "managed_redis_name")
		resourceGroupName := OutputString(t, terraformOptions, "resource_group_name")
		defaultDatabasePort := OutputString(t, terraformOptions, "default_database_port")

		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.NotEmpty(t, defaultDatabasePort)
	})
}

// TestManagedRedisSecurityConfiguration validates the secure fixture posture.
func TestManagedRedisSecurityConfiguration(t *testing.T) {
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
		publicNetworkAccess := OutputString(t, terraformOptions, "public_network_access")
		assert.Equal(t, "Disabled", publicNetworkAccess)
	})
}

// TestManagedRedisLifecycle validates idempotent apply behavior on the basic fixture.
func TestManagedRedisLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceID := OutputString(t, terraformOptions, "managed_redis_id")
	assert.NotEmpty(t, resourceID)

	terraform.Apply(t, terraformOptions)
	updatedResourceID := OutputString(t, terraformOptions, "managed_redis_id")
	assert.Equal(t, resourceID, updatedResourceID)
}

// TestManagedRedisGeoReplicationIntegration validates geo-replication membership fixture.
func TestManagedRedisGeoReplicationIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/geo-replication")
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
		linkedIDs := OutputList(t, terraformOptions, "geo_replication_linked_ids")
		assert.Len(t, linkedIDs, 1)
	})
}
