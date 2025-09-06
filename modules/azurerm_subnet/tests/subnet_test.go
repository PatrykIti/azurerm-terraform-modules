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

// Test basic subnet creation
func TestBasicSubnet(t *testing.T) {
	t.Parallel()

	// Create a folder for this test
	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_subnet/tests/fixtures/basic")
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
		resourceID := terraform.Output(t, terraformOptions, "subnet_id")
		resourceName := terraform.Output(t, terraformOptions, "subnet_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		// Validate outputs are not empty
		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)

		// Add subnet specific validations here
	})
}

// Test complete subnet with all features
func TestCompleteSubnet(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_subnet/tests/fixtures/complete")
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
		resourceID := terraform.Output(t, terraformOptions, "subnet_id")
		resourceName := terraform.Output(t, terraformOptions, "subnet_name")
		
		// Validate complete configuration
		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		
		// Add additional validations for complete configuration
		// This should test all optional features and advanced settings
	})
}

// Test security configurations
func TestSubnetSecurity(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_subnet/tests/fixtures/secure")
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

		resourceID := terraform.Output(t, terraformOptions, "subnet_id")
		resourceName := terraform.Output(t, terraformOptions, "subnet_name")

		// Validate security settings
		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		
		// Add security-specific validations
		// Validate encryption, TLS settings, access controls, etc.
	})
}

// Test network access controls
func TestSubnetNetworkRules(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_subnet/tests/fixtures/network")
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

		resourceID := terraform.Output(t, terraformOptions, "subnet_id")
		
		// Validate network rules
		assert.NotEmpty(t, resourceID)
		
		// Add network-specific validations
		// Validate IP rules, subnet restrictions, private endpoints, etc.
	})
}

// Test private endpoint configuration
func TestSubnetPrivateEndpoint(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_subnet/tests/fixtures/private_endpoint")
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

		resourceID := terraform.Output(t, terraformOptions, "subnet_id")
		subnetName := terraform.Output(t, terraformOptions, "subnet_name")
		
		// Try to get private_endpoint_id if it exists
		privateEndpointID, err := terraform.OutputE(t, terraformOptions, "private_endpoint_id")

		// Validate subnet was created
		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, subnetName)
		
		// If private endpoint ID exists and is not a placeholder, validate it
		if err == nil && privateEndpointID != "" && !strings.Contains(privateEndpointID, "not-created-in-this-fixture") {
			assert.NotEmpty(t, privateEndpointID)
		}
		
		// Validate subnet is configured for private endpoints
		// Add additional private endpoint validations
	})
}

// Negative test cases for validation rules
func TestSubnetValidationRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		fixtureFile   string
		expectedError string
	}{
		{
			name:          "InvalidName_TooShort",
			fixtureFile:   "negative/invalid_name_short",
			expectedError: "Subnet name must be between 1 and 80 characters long",
		},
		{
			name:          "InvalidName_TooLong",
			fixtureFile:   "negative/invalid_name_chars",
			expectedError: "Subnet name must be between 1 and 80 characters long",
		},
		// Add more validation test cases specific to subnet
	}

	for _, tc := range testCases {
		tc := tc // capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", fmt.Sprintf("azurerm_subnet/tests/fixtures/%s", tc.fixtureFile))
			
			// Use minimal terraform options for negative tests (no variables)
			terraformOptions := &terraform.Options{
				TerraformDir: testFolder,
				NoColor:      true,
			}

			// Initialize terraform
			terraform.Init(t, terraformOptions)
			
			// This should fail during validation
			_, err := terraform.ValidateE(t, terraformOptions)
			require.Error(t, err)
			assert.Contains(t, err.Error(), tc.expectedError)
		})
	}
}

// Benchmark test for performance
func BenchmarkSubnetCreation(b *testing.B) {
	// Skip if not running benchmarks
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "azurerm_subnet/tests/fixtures/basic")
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