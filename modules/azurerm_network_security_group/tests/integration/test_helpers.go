package test

import (
	"testing"
	"os"

	"github.com/gruntwork-io/terratest/modules/azure"
)

// GetAzureRegion returns the Azure region to use for testing
func GetAzureRegion(t *testing.T) string {
	region := os.Getenv("AZURE_REGION")
	if region == "" {
		region = "eastus"
	}
	return region
}

// GetResourceGroupName returns the resource group name from environment or generates one
func GetResourceGroupName(t *testing.T, suffix string) string {
	baseRG := os.Getenv("TEST_RESOURCE_GROUP_NAME")
	if baseRG != "" {
		return baseRG + "-" + suffix
	}
	return "rg-test-" + suffix
}

// SkipTestIfNoAzureCredentials skips the test if Azure credentials are not available
func SkipTestIfNoAzureCredentials(t *testing.T) {
	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("Skipping test due to missing Azure credentials. Set ARM_SUBSCRIPTION_ID to run this test.")
	}
}

// GetDefaultTags returns default tags for test resources
func GetDefaultTags(testName string) map[string]string {
	return map[string]string{
		"Environment": "Test",
		"ManagedBy":   "Terratest",
		"TestName":    testName,
		"Purpose":     "Integration Testing",
	}
}

// CleanupResourceGroup deletes the resource group and handles errors
func CleanupResourceGroup(t *testing.T, resourceGroupName string) {
	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Logf("Skipping cleanup: No subscription ID found")
		return
	}

	exists := azure.ResourceGroupExists(t, resourceGroupName, subscriptionID)
	if exists {
		azure.DeleteResourceGroup(t, resourceGroupName, subscriptionID)
		t.Logf("Deleted resource group: %s", resourceGroupName)
	}
}