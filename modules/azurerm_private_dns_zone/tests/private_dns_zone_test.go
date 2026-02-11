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

// Test basic private_dns_zone creation
func TestBasicPrivateDnsZone(t *testing.T) {
	t.Parallel()

	// Create a folder for this test
	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	// Deploy the infrastructure
	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	// Validate the infrastructure
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		// Get outputs
		resourceID := terraform.Output(t, terraformOptions, "private_dns_zone_id")
		resourceName := terraform.Output(t, terraformOptions, "private_dns_zone_name")
		randomSuffix, ok := terraformOptions.Vars["random_suffix"].(string)
		require.True(t, ok, "random_suffix must be available in terraform options")

		assertPrivateDnsZoneOutputs(
			t,
			resourceID,
			resourceName,
			fmt.Sprintf("example-%s.internal", randomSuffix),
			fmt.Sprintf("rg-pdns-basic-%s", randomSuffix),
		)
	})
}

// Test complete private_dns_zone with all features
func TestCompletePrivateDnsZone(t *testing.T) {
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

		// Get outputs
		resourceID := terraform.Output(t, terraformOptions, "private_dns_zone_id")
		resourceName := terraform.Output(t, terraformOptions, "private_dns_zone_name")
		randomSuffix, ok := terraformOptions.Vars["random_suffix"].(string)
		require.True(t, ok, "random_suffix must be available in terraform options")

		assertPrivateDnsZoneOutputs(
			t,
			resourceID,
			resourceName,
			fmt.Sprintf("privatelink-%s.blob.core.windows.net", randomSuffix),
			fmt.Sprintf("rg-pdns-complete-%s", randomSuffix),
		)
	})
}

// Test security-focused configuration
func TestSecurePrivateDnsZone(t *testing.T) {
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

		resourceID := terraform.Output(t, terraformOptions, "private_dns_zone_id")
		resourceName := terraform.Output(t, terraformOptions, "private_dns_zone_name")
		randomSuffix, ok := terraformOptions.Vars["random_suffix"].(string)
		require.True(t, ok, "random_suffix must be available in terraform options")

		assertPrivateDnsZoneOutputs(
			t,
			resourceID,
			resourceName,
			fmt.Sprintf("privatelink-%s.vaultcore.azure.net", randomSuffix),
			fmt.Sprintf("rg-pdns-secure-%s", randomSuffix),
		)
	})
}

// Negative test cases for validation rules
func TestPrivateDnsZoneValidationRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		fixtureFile   string
		expectedError string
	}{
		{
			name:          "InvalidName",
			fixtureFile:   "negative",
			expectedError: "name must be a valid DNS zone name",
		},
	}

	for _, tc := range testCases {
		tc := tc // capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", fmt.Sprintf("tests/fixtures/%s", tc.fixtureFile))

			// Use minimal terraform options for negative tests (no variables)
			terraformOptions := &terraform.Options{
				TerraformDir: testFolder,
				NoColor:      true,
			}

			// This should fail during plan/apply
			_, err := terraform.InitAndPlanE(t, terraformOptions)
			require.Error(t, err)
			if tc.expectedError != "" {
				assert.Contains(t, err.Error(), tc.expectedError)
			}
		})
	}
}

// Benchmark test for performance
func BenchmarkPrivateDnsZoneCreation(b *testing.B) {
	// Skip if not running benchmarks
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(b, testFolder)

	// Cleanup after benchmark
	defer terraform.Destroy(b, terraformOptions)

	// Run the benchmark
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		// Generate unique name for each iteration
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])

		terraform.InitAndApply(b, terraformOptions)
		terraform.Destroy(b, terraformOptions)
	}
}

func assertPrivateDnsZoneOutputs(t *testing.T, resourceID, resourceName, expectedName, expectedResourceGroup string) {
	t.Helper()

	assert.NotEmpty(t, resourceID)
	assert.NotEmpty(t, resourceName)
	assert.Equal(t, expectedName, resourceName)
	assert.Contains(
		t,
		strings.ToLower(resourceID),
		strings.ToLower(fmt.Sprintf("/resourcegroups/%s/", expectedResourceGroup)),
	)
	assert.Contains(
		t,
		strings.ToLower(resourceID),
		strings.ToLower(fmt.Sprintf("/providers/microsoft.network/privatednszones/%s", expectedName)),
	)
}

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	// Generate a unique ID for resources
	timestamp := time.Now().UnixNano() % 1000 // Last 3 digits for more variation
	baseID := strings.ToLower(random.UniqueId())
	uniqueID := fmt.Sprintf("%s%03d", baseID[:5], timestamp)

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"random_suffix": uniqueID,
			"location":      "northeurope",
		},
		NoColor: true,
		// Retry configuration
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":               "Timeout error - retrying",
			".*ResourceGroupNotFound.*": "Resource group not found - retrying",
			".*AlreadyExists.*":         "Resource already exists - retrying",
			".*TooManyRequests.*":       "Too many requests - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
