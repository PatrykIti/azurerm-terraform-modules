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

// Test basic application_insights creation
func TestBasicApplicationInsights(t *testing.T) {
	t.Parallel()

	// Create a folder for this test
	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/basic")
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
		resourceID := terraform.Output(t, terraformOptions, "application_insights_id")
		resourceName := terraform.Output(t, terraformOptions, "application_insights_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		// Validate outputs are not empty
		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)

		// Add application_insights specific validations here
	})
}

// Test complete application_insights with all features
func TestCompleteApplicationInsights(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/complete")
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
		resourceID := terraform.Output(t, terraformOptions, "application_insights_id")
		resourceName := terraform.Output(t, terraformOptions, "application_insights_name")
		
		// Validate complete configuration
		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		
		// Add additional validations for complete configuration
		// This should test all optional features and advanced settings
	})
}

// Test security configurations
func TestSecureApplicationInsights(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/secure")
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

		resourceID := terraform.Output(t, terraformOptions, "application_insights_id")
		resourceName := terraform.Output(t, terraformOptions, "application_insights_name")

		// Validate security settings
		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		
		// Add security-specific validations
		// Validate encryption, TLS settings, access controls, etc.
	})
}

// Test API keys
func TestApplicationInsightsApiKeys(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/api-keys")
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

		resourceID := terraform.Output(t, terraformOptions, "application_insights_id")
		assert.NotEmpty(t, resourceID)
	})
}

// Test analytics items
func TestApplicationInsightsAnalyticsItems(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/analytics-items")
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

		resourceID := terraform.Output(t, terraformOptions, "application_insights_id")
		assert.NotEmpty(t, resourceID)
	})
}

// Test classic web tests
func TestApplicationInsightsWebTests(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/web-tests")
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

		resourceID := terraform.Output(t, terraformOptions, "application_insights_id")
		assert.NotEmpty(t, resourceID)
	})
}

// Test standard web tests
func TestApplicationInsightsStandardWebTests(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/standard-web-tests")
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

		resourceID := terraform.Output(t, terraformOptions, "application_insights_id")
		assert.NotEmpty(t, resourceID)
	})
}

// Test workbooks
func TestApplicationInsightsWorkbooks(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/workbooks")
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

		resourceID := terraform.Output(t, terraformOptions, "application_insights_id")
		assert.NotEmpty(t, resourceID)
	})
}

// Test smart detection rules
func TestApplicationInsightsSmartDetectionRules(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/smart-detection-rules")
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

		resourceID := terraform.Output(t, terraformOptions, "application_insights_id")
		assert.NotEmpty(t, resourceID)
	})
}

// Negative test cases for validation rules
func TestApplicationInsightsValidationRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		fixtureFile   string
		expectedError string
	}{
		{
			name:          "InvalidName",
			fixtureFile:   "negative",
			expectedError: "",
		},
		// Add more validation test cases specific to application_insights
	}

	for _, tc := range testCases {
		tc := tc // capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", fmt.Sprintf("fixtures/%s", tc.fixtureFile))
			
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
func BenchmarkApplicationInsightsCreation(b *testing.B) {
	// Skip if not running benchmarks
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(b, ".", "fixtures/basic")
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
			".*timeout.*":                    "Timeout error - retrying",
			".*ResourceGroupNotFound.*":      "Resource group not found - retrying",
			".*AlreadyExists.*":              "Resource already exists - retrying",
			".*TooManyRequests.*":            "Too many requests - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
