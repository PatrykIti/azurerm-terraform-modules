package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic postgresql_flexible_server creation
func TestBasicPostgresqlFlexibleServer(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		resourceID := terraform.Output(t, terraformOptions, "postgresql_flexible_server_id")
		resourceName := terraform.Output(t, terraformOptions, "postgresql_flexible_server_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		databaseName := terraform.Output(t, terraformOptions, "database_name")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.NotEmpty(t, databaseName)

		helper := NewPostgresqlFlexibleServerHelper(t)
		server := helper.GetServer(t, resourceGroupName, resourceName)
		assert.NotNil(t, server.ID)
		assert.NotNil(t, server.Name)
	})
}

// Test complete postgresql_flexible_server with all features
func TestCompletePostgresqlFlexibleServer(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		resourceID := terraform.Output(t, terraformOptions, "postgresql_flexible_server_id")
		resourceName := terraform.Output(t, terraformOptions, "postgresql_flexible_server_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		publicAccess := OutputBool(t, terraformOptions, "public_network_access_enabled")

		assert.NotEmpty(t, resourceID)
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

// Test security configurations
func TestSecurePostgresqlFlexibleServer(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		resourceID := terraform.Output(t, terraformOptions, "postgresql_flexible_server_id")
		resourceName := terraform.Output(t, terraformOptions, "postgresql_flexible_server_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		publicAccess := OutputBool(t, terraformOptions, "public_network_access_enabled")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.False(t, publicAccess)
	})
}

// Test network access controls
func TestNetworkPostgresqlFlexibleServer(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/network")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		resourceID := terraform.Output(t, terraformOptions, "postgresql_flexible_server_id")
		firewallRules := terraform.OutputList(t, terraformOptions, "firewall_rule_names")

		assert.NotEmpty(t, resourceID)
		assert.Len(t, firewallRules, 1)
	})
}

// Negative test cases for validation rules
func TestPostgresqlFlexibleServerValidationRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		fixtureFile   string
		expectedError string
	}{
		{
			name:          "InvalidName",
			fixtureFile:   "negative",
			expectedError: "name",
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
			if tc.expectedError != "" {
				assert.Contains(t, strings.ToLower(err.Error()), strings.ToLower(tc.expectedError))
			}
		})
	}
}

// Benchmark test for performance
func BenchmarkPostgresqlFlexibleServerCreation(b *testing.B) {
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

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	timestamp := time.Now().UnixNano() % 1000
	baseID := strings.ToLower(random.UniqueId())
	uniqueID := fmt.Sprintf("%s%03d", baseID[:5], timestamp)

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"random_suffix": uniqueID,
			"location":      "northeurope",
		},
		NoColor: true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":               "Timeout error - retrying",
			".*ResourceGroupNotFound.*": "Resource group not found - retrying",
			".*AlreadyExists.*":         "Resource already exists - retrying",
			".*TooManyRequests.*":       "Too many requests - retrying",
			".*ServerDropping.*":        "Server is in dropping state - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
