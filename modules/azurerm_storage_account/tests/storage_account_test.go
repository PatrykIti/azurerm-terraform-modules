package test

import (
	"crypto/tls"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/storage/armstorage"
	// "github.com/gruntwork-io/terratest/modules/azure" // Commented out due to SQL import issue
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic storage account creation
func TestBasicStorageAccount(t *testing.T) {
	t.Parallel()

	// Create a folder for this test
	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/simple")
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
		storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		storageAccountID := terraform.Output(t, terraformOptions, "storage_account_id")

		// Validate outputs are not empty
		assert.NotEmpty(t, storageAccountName)
		assert.NotEmpty(t, resourceGroupName)
		assert.NotEmpty(t, storageAccountID)

		// Use our helper instead of azure module due to import issues
		helper := NewStorageAccountHelper(t)

		// Get storage account properties
		storageAccount := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
		
		// Validate basic properties
		assert.Equal(t, armstorage.SKUNameStandardLRS, *storageAccount.SKU.Name)
		assert.Equal(t, armstorage.KindStorageV2, *storageAccount.Kind)
		assert.Equal(t, armstorage.ProvisioningStateSucceeded, *storageAccount.Properties.ProvisioningState)
		
		// Validate secure defaults
		assert.True(t, *storageAccount.Properties.EnableHTTPSTrafficOnly)
		assert.Equal(t, armstorage.MinimumTLSVersionTLS12, *storageAccount.Properties.MinimumTLSVersion)
	})
}

// Test complete storage account with all features
func TestCompleteStorageAccount(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/complete")
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
		storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		containerNames := terraform.OutputList(t, terraformOptions, "container_names")
		primaryBlobEndpoint := terraform.Output(t, terraformOptions, "primary_blob_endpoint")

		// Use our helper instead of azure module
		helper := NewStorageAccountHelper(t)
		storageAccount := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
		
		// Validate advanced features
		assert.Equal(t, armstorage.SKUNameStandardZRS, *storageAccount.SKU.Name)
		assert.True(t, *storageAccount.Properties.EnableHTTPSTrafficOnly)
		assert.Equal(t, armstorage.MinimumTLSVersionTLS12, *storageAccount.Properties.MinimumTLSVersion)
		
		// Validate containers were created
		assert.Equal(t, 3, len(containerNames))
		assert.Contains(t, containerNames, "data")
		assert.Contains(t, containerNames, "logs")
		assert.Contains(t, containerNames, "backups")

		// Validate blob endpoint is accessible (should fail due to network rules)
		tlsConfig := &tls.Config{InsecureSkipVerify: true}
		err := http_helper.HttpGetWithRetryE(t, primaryBlobEndpoint, tlsConfig, 403, "", 3, 5*time.Second)
		assert.NoError(t, err) // Should get 403 due to network restrictions
	})
}

// Test security configurations
func TestStorageAccountSecurity(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/security")
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

		storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		// Use our helper instead of azure module
		helper := NewStorageAccountHelper(t)
		storageAccount := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)

		// Validate security settings
		assert.True(t, *storageAccount.Properties.EnableHTTPSTrafficOnly)
		assert.Equal(t, armstorage.MinimumTLSVersionTLS12, *storageAccount.Properties.MinimumTLSVersion)
		assert.True(t, *storageAccount.Properties.AllowBlobPublicAccess == false)
		
		// Validate encryption settings
		assert.NotNil(t, storageAccount.Properties.Encryption)
		assert.True(t, *storageAccount.Properties.Encryption.RequireInfrastructureEncryption)
		assert.Equal(t, armstorage.KeySourceMicrosoftStorage, *storageAccount.Properties.Encryption.KeySource)
		
		// Validate blob encryption
		assert.True(t, *storageAccount.Properties.Encryption.Services.Blob.Enabled)
		assert.Equal(t, armstorage.KeyTypeAccount, *storageAccount.Properties.Encryption.Services.Blob.KeyType)
		
		// Validate file encryption
		assert.True(t, *storageAccount.Properties.Encryption.Services.File.Enabled)
		assert.Equal(t, armstorage.KeyTypeAccount, *storageAccount.Properties.Encryption.Services.File.KeyType)
	})
}

// Test network access controls
func TestStorageAccountNetworkRules(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/network")
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

		storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		// Use our helper instead of azure module
		helper := NewStorageAccountHelper(t)
		storageAccount := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)

		// Validate network rules
		assert.NotNil(t, storageAccount.Properties.NetworkRuleSet)
		assert.Equal(t, armstorage.DefaultActionDeny, *storageAccount.Properties.NetworkRuleSet.DefaultAction)
		
		// Validate IP rules
		if storageAccount.Properties.NetworkRuleSet.IPRules != nil {
			ipRules := storageAccount.Properties.NetworkRuleSet.IPRules
			assert.NotEmpty(t, ipRules)
			if len(ipRules) > 0 {
				assert.Equal(t, "203.0.113.0/24", *ipRules[0].IPAddressOrRange)
			}
		}
		
		// Validate virtual network rules
		assert.NotEmpty(t, storageAccount.Properties.NetworkRuleSet.VirtualNetworkRules)
		
		// Validate bypass settings
		assert.Equal(t, armstorage.BypassAzureServices, *storageAccount.Properties.NetworkRuleSet.Bypass)
	})
}

// Test private endpoint configuration
func TestStorageAccountPrivateEndpoint(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/private_endpoint")
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

		storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		privateEndpointID := terraform.Output(t, terraformOptions, "private_endpoint_id")

		// Validate private endpoint was created
		assert.NotEmpty(t, privateEndpointID)

		// Use our helper instead of azure module
		helper := NewStorageAccountHelper(t)
		storageAccount := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)

		// Validate public network access is disabled
		assert.Equal(t, armstorage.PublicNetworkAccessDisabled, *storageAccount.Properties.PublicNetworkAccess)
		
		// Validate network rules still apply
		assert.Equal(t, armstorage.DefaultActionDeny, *storageAccount.Properties.NetworkRuleSet.DefaultAction)
	})
}

// Negative test cases for validation rules
func TestStorageAccountValidationRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		fixtureFile   string
		expectedError string
	}{
		{
			name:          "InvalidStorageAccountName_TooShort",
			fixtureFile:   "negative/invalid_name_short.tf",
			expectedError: "name must be between 3 and 24 characters",
		},
		{
			name:          "InvalidStorageAccountName_InvalidChars",
			fixtureFile:   "negative/invalid_name_chars.tf",
			expectedError: "name can only contain lowercase letters and numbers",
		},
		{
			name:          "InvalidAccountTier",
			fixtureFile:   "negative/invalid_account_tier.tf",
			expectedError: "account_tier must be either 'Standard' or 'Premium'",
		},
		{
			name:          "InvalidReplicationType",
			fixtureFile:   "negative/invalid_replication_type.tf",
			expectedError: "Invalid replication type",
		},
		{
			name:          "InvalidContainerAccessType",
			fixtureFile:   "negative/invalid_container_access.tf",
			expectedError: "container_access_type must be one of: private, blob, container",
		},
	}

	for _, tc := range testCases {
		tc := tc // capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", fmt.Sprintf("azurerm_storage_account/tests/fixtures/%s", tc.fixtureFile))
			terraformOptions := getTerraformOptions(t, testFolder)

			// This should fail during plan/apply
			_, err := terraform.InitAndPlanE(t, terraformOptions)
			require.Error(t, err)
			assert.Contains(t, err.Error(), tc.expectedError)
		})
	}
}

// Benchmark test for performance
func BenchmarkStorageAccountCreation(b *testing.B) {
	// Skip if not running benchmarks
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "azurerm_storage_account/tests/fixtures/simple")
	terraformOptions := getTerraformOptions(b, testFolder)

	// Cleanup after benchmark
	defer terraform.Destroy(b, terraformOptions)

	// Run the benchmark
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		// Generate unique name for each iteration
		terraformOptions.Vars["storage_account_suffix"] = fmt.Sprintf("%d", i)
		
		terraform.InitAndApply(b, terraformOptions)
		terraform.Destroy(b, terraformOptions)
	}
}

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	// Generate a unique ID for resources
	uniqueID := strings.ToLower(random.UniqueId())
	
	// Azure subscription ID (will be set from environment)
	subscriptionID := os.Getenv("AZURE_SUBSCRIPTION_ID")
	require.NotEmpty(t, subscriptionID, "AZURE_SUBSCRIPTION_ID is required")

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"random_suffix":   uniqueID,
			"subscription_id": subscriptionID,
			"location":        "northeurope",
		},
		NoColor: true,
		// Retry configuration
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":                    "Timeout error - retrying",
			".*ResourceGroupNotFound.*":      "Resource group not found - retrying",
			".*StorageAccountAlreadyTaken.*": "Storage account name taken - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}

// removed - already defined in test_helpers.go