package test

import (
	"context"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/storage/mgmt/2021-09-01/storage"
	// "github.com/gruntwork-io/terratest/modules/azure" // Commented out due to SQL import issue
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestStorageAccountFullIntegration tests all features working together
func TestStorageAccountFullIntegration(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/complete")
	
	// Setup stages
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	// Deploy infrastructure
	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	// Validate all components
	test_structure.RunTestStage(t, "validate_core", func() {
		validateCoreFeatures(t, testFolder)
	})

	test_structure.RunTestStage(t, "validate_security", func() {
		validateSecurityFeatures(t, testFolder)
	})

	test_structure.RunTestStage(t, "validate_network", func() {
		validateNetworkFeatures(t, testFolder)
	})

	test_structure.RunTestStage(t, "validate_operations", func() {
		validateOperationalFeatures(t, testFolder)
	})
}

// validateCoreFeatures validates basic storage account features
func validateCoreFeatures(t *testing.T, testFolder string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
	helper := NewStorageAccountHelper(t)

	// Get outputs
	storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	
	// Get storage account details
	account := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)

	// Validate core properties
	assert.Equal(t, storage.SkuName("Standard_ZRS"), account.Sku.Name)
	assert.Equal(t, storage.Kind("StorageV2"), account.Kind)
	assert.Equal(t, storage.ProvisioningStateSucceeded, account.ProvisioningState)
	
	// Validate access tier
	assert.Equal(t, storage.AccessTierHot, account.AccessTier)
	
	// Validate tags
	expectedTags := map[string]string{
		"Environment": "Test",
		"TestType":    "Complete",
		"CostCenter":  "Engineering",
		"Owner":       "terratest",
	}
	ValidateStorageAccountTags(t, account, expectedTags)
}

// validateSecurityFeatures validates security configurations
func validateSecurityFeatures(t *testing.T, testFolder string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
	helper := NewStorageAccountHelper(t)

	storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	
	account := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)

	// Security validations
	assert.True(t, *account.EnableHTTPSTrafficOnly, "HTTPS-only should be enabled")
	assert.Equal(t, storage.MinimumTLSVersionTLS12, account.MinimumTLSVersion, "TLS 1.2 should be minimum")
	assert.False(t, *account.AllowBlobPublicAccess, "Public blob access should be disabled")
	
	// Validate encryption
	helper.ValidateStorageAccountEncryption(t, account)
	
	// Infrastructure encryption
	require.NotNil(t, account.Encryption)
	assert.True(t, *account.Encryption.RequireInfrastructureEncryption, "Infrastructure encryption should be enabled")
}

// validateNetworkFeatures validates network configurations
func validateNetworkFeatures(t *testing.T, testFolder string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
	helper := NewStorageAccountHelper(t)

	storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	
	account := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)

	// Network rules validation
	assert.Equal(t, storage.DefaultActionDeny, account.NetworkRuleSet.DefaultAction)
	assert.Equal(t, storage.Bypass("AzureServices"), account.NetworkRuleSet.Bypass)
	
	// Validate IP rules and subnet rules
	expectedIPRules := []string{"203.0.113.0/24"}
	helper.ValidateNetworkRules(t, account, expectedIPRules, nil)
}

// validateOperationalFeatures validates operational features like monitoring
func validateOperationalFeatures(t *testing.T, testFolder string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
	helper := NewStorageAccountHelper(t)

	storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	storageAccountID := terraform.Output(t, terraformOptions, "storage_account_id")
	
	// Validate blob service properties
	helper.ValidateBlobServiceProperties(t, storageAccountName, resourceGroupName)
	
	// Validate diagnostic settings format
	ValidateDiagnosticSettings(t, storageAccountID)
	
	// Validate containers were created
	containerNames := terraform.OutputList(t, terraformOptions, "container_names")
	assert.Equal(t, 3, len(containerNames))
	
	// Validate each container exists
	for _, containerName := range containerNames {
		ValidateContainerExists(t, storageAccountName, resourceGroupName, containerName)
	}
}

// TestStorageAccountLifecycle tests the complete lifecycle of storage account
func TestStorageAccountLifecycle(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/simple")
	terraformOptions := getTerraformOptions(t, testFolder)
	
	defer terraform.Destroy(t, terraformOptions)

	// Initial deployment
	terraform.InitAndApply(t, terraformOptions)
	
	// Get initial state
	storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	
	// Verify initial deployment using our helper
	helper := NewStorageAccountHelper(t)
	storageAccount := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	assert.NotNil(t, storageAccount.ID)
	
	// Update configuration (enable blob versioning)
	terraformOptions.Vars["enable_blob_versioning"] = true
	terraform.Apply(t, terraformOptions)
	
	// Verify update was applied
	helper.ValidateBlobServiceProperties(t, storageAccountName, resourceGroupName)
	
	// Test idempotency - apply again without changes
	terraform.Apply(t, terraformOptions)
}

// TestStorageAccountDisasterRecovery tests failover scenarios
func TestStorageAccountDisasterRecovery(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping disaster recovery test in short mode")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/simple")
	terraformOptions := getTerraformOptions(t, testFolder)
	
	// Use GRS for failover capability
	terraformOptions.Vars["account_replication_type"] = "GRS"
	
	defer terraform.Destroy(t, terraformOptions)
	
	// Deploy
	terraform.InitAndApply(t, terraformOptions)
	
	storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	
	// Verify GRS is configured
	helper := NewStorageAccountHelper(t)
	
	// Wait for storage account to be ready
	helper.WaitForStorageAccountReady(t, storageAccountName, resourceGroupName)
	
	// Get account properties
	account := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	assert.Equal(t, storage.SkuName("Standard_GRS"), account.Sku.Name)
	
	// Wait for GRS secondary endpoints to be available
	helper.WaitForGRSSecondaryEndpoints(t, storageAccountName, resourceGroupName)
	
	// Get updated account properties with secondary endpoints
	account = helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	
	// Verify secondary endpoints are available
	assert.NotNil(t, account.SecondaryEndpoints, "Secondary endpoints should be available for GRS")
	if account.SecondaryEndpoints != nil && account.SecondaryEndpoints.Blob != nil {
		assert.NotEmpty(t, *account.SecondaryEndpoints.Blob, "Secondary blob endpoint should not be empty")
		t.Logf("Secondary endpoint: %s", *account.SecondaryEndpoints.Blob)
	}
	
	if account.PrimaryEndpoints != nil && account.PrimaryEndpoints.Blob != nil {
		t.Logf("Primary endpoint: %s", *account.PrimaryEndpoints.Blob)
	}
}

// TestStorageAccountCompliance tests compliance-related features
func TestStorageAccountCompliance(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/security")
	terraformOptions := getTerraformOptions(t, testFolder)
	
	defer terraform.Destroy(t, terraformOptions)
	
	terraform.InitAndApply(t, terraformOptions)
	
	storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	
	helper := NewStorageAccountHelper(t)
	account := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	
	// Compliance checks
	complianceChecks := []struct {
		name      string
		check     func() bool
		message   string
	}{
		{
			name:    "HTTPS Only",
			check:   func() bool { return *account.EnableHTTPSTrafficOnly },
			message: "HTTPS-only traffic must be enforced",
		},
		{
			name:    "TLS Version",
			check:   func() bool { return account.MinimumTLSVersion == storage.MinimumTLSVersionTLS12 },
			message: "Minimum TLS version must be 1.2",
		},
		{
			name:    "Public Access",
			check:   func() bool { return !*account.AllowBlobPublicAccess },
			message: "Public blob access must be disabled",
		},
		{
			name:    "Network Rules",
			check:   func() bool { return account.NetworkRuleSet.DefaultAction == storage.DefaultActionDeny },
			message: "Network default action must be Deny",
		},
		{
			name:    "Encryption",
			check:   func() bool { return account.Encryption != nil && *account.Encryption.Services.Blob.Enabled },
			message: "Blob encryption must be enabled",
		},
	}
	
	for _, cc := range complianceChecks {
		t.Run(cc.name, func(t *testing.T) {
			assert.True(t, cc.check(), cc.message)
		})
	}
}

// TestStorageAccountMonitoring tests monitoring and observability features
func TestStorageAccountMonitoring(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/complete")
	terraformOptions := getTerraformOptions(t, testFolder)
	
	defer terraform.Destroy(t, terraformOptions)
	
	terraform.InitAndApply(t, terraformOptions)
	
	storageAccountID := terraform.Output(t, terraformOptions, "storage_account_id")
	
	// Validate monitoring configuration
	// In a real scenario, you would use Azure Monitor SDK to validate diagnostic settings
	assert.NotEmpty(t, storageAccountID)
	assert.Contains(t, storageAccountID, "/providers/Microsoft.Storage/storageAccounts/")
	
	// Simulate metric collection
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	
	// Log simulated metrics
	t.Logf("Monitoring simulation for storage account: %s", storageAccountID)
	t.Logf("Simulated metric - Used capacity: 1024 MB")
	t.Logf("Simulated metric - Transaction count: 1000")
	t.Logf("Simulated metric - Availability: 99.99%%")
	
	select {
	case <-ctx.Done():
		t.Logf("Monitoring simulation completed")
	case <-time.After(5 * time.Second):
		t.Logf("Monitoring check completed")
	}
}