package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestPostgresqlFlexibleServerDatabaseFullIntegration validates a complete deployment.
func TestPostgresqlFlexibleServerDatabaseFullIntegration(t *testing.T) {
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

		resourceID := terraform.Output(t, terraformOptions, "postgresql_flexible_server_database_id")
		resourceName := terraform.Output(t, terraformOptions, "postgresql_flexible_server_database_name")
		charset := terraform.Output(t, terraformOptions, "database_charset")
		collation := terraform.Output(t, terraformOptions, "database_collation")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.Equal(t, "UTF8", charset)
		assert.Equal(t, "en_US.utf8", collation)
	})
}

// TestPostgresqlFlexibleServerDatabaseLifecycle tests basic lifecycle behavior.
func TestPostgresqlFlexibleServerDatabaseLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceID := terraform.Output(t, terraformOptions, "postgresql_flexible_server_database_id")
	assert.NotEmpty(t, resourceID)

	terraform.Apply(t, terraformOptions)
	updatedResourceID := terraform.Output(t, terraformOptions, "postgresql_flexible_server_database_id")
	assert.Equal(t, resourceID, updatedResourceID)
}
