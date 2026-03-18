package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic Managed Redis creation.
func TestBasicManagedRedis(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
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

		resourceID := OutputString(t, terraformOptions, "managed_redis_id")
		resourceName := OutputString(t, terraformOptions, "managed_redis_name")
		resourceGroupName := OutputString(t, terraformOptions, "resource_group_name")
		publicNetworkAccess := OutputString(t, terraformOptions, "public_network_access")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.Equal(t, "Enabled", publicNetworkAccess)
	})
}

// Test complete Managed Redis configuration.
func TestCompleteManagedRedis(t *testing.T) {
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

		resourceID := OutputString(t, terraformOptions, "managed_redis_id")
		resourceName := OutputString(t, terraformOptions, "managed_redis_name")
		resourceGroupName := OutputString(t, terraformOptions, "resource_group_name")
		defaultDatabasePort := OutputString(t, terraformOptions, "default_database_port")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.NotEmpty(t, defaultDatabasePort)
	})
}

// Test secure Managed Redis configuration.
func TestSecureManagedRedis(t *testing.T) {
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

		resourceID := OutputString(t, terraformOptions, "managed_redis_id")
		resourceName := OutputString(t, terraformOptions, "managed_redis_name")
		publicNetworkAccess := OutputString(t, terraformOptions, "public_network_access")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.Equal(t, "Disabled", publicNetworkAccess)
	})
}

// Test Managed Redis geo-replication fixture.
func TestManagedRedisGeoReplication(t *testing.T) {
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

		primaryID := OutputString(t, terraformOptions, "primary_managed_redis_id")
		secondaryID := OutputString(t, terraformOptions, "secondary_managed_redis_id")
		linkedIDs := OutputList(t, terraformOptions, "geo_replication_linked_ids")

		assert.NotEmpty(t, primaryID)
		assert.NotEmpty(t, secondaryID)
		assert.Len(t, linkedIDs, 1)
	})
}

// Negative test cases for validation rules.
func TestManagedRedisValidationRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		fixtureFile   string
		expectedError string
	}{
		{
			name:          "InvalidPublicNetworkAccess",
			fixtureFile:   "negative",
			expectedError: "public_network_access",
		},
	}

	for _, tc := range testCases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", fmt.Sprintf("tests/fixtures/%s", tc.fixtureFile))
			terraformOptions := &terraform.Options{
				TerraformDir: testFolder,
				NoColor:      true,
			}

			_, err := terraform.InitAndPlanE(t, terraformOptions)
			require.Error(t, err)
			assert.Contains(t, strings.ToLower(err.Error()), strings.ToLower(tc.expectedError))
		})
	}
}

// Benchmark Managed Redis creation.
func BenchmarkManagedRedisCreation(b *testing.B) {
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(b, testFolder)
	defer terraform.Destroy(b, terraformOptions)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])
		terraform.InitAndApply(b, terraformOptions)
		terraform.Destroy(b, terraformOptions)
	}
}

func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	return NewTerraformOptions(t, terraformDir)
}
