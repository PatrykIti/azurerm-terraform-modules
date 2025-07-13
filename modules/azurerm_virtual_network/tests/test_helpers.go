package test

import (
	"context"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork/v5"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestConfig holds common test configuration
type TestConfig struct {
	SubscriptionID    string
	TenantID         string
	ClientID         string
	ClientSecret     string
	Location         string
	ResourceGroup    string
	UniqueID         string
}

// GetTestConfig returns a test configuration with required Azure credentials
func GetTestConfig(t *testing.T) *TestConfig {
	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID environment variable must be set")

	tenantID := os.Getenv("ARM_TENANT_ID")
	require.NotEmpty(t, tenantID, "ARM_TENANT_ID environment variable must be set")

	clientID := os.Getenv("ARM_CLIENT_ID")
	require.NotEmpty(t, clientID, "ARM_CLIENT_ID environment variable must be set")

	clientSecret := os.Getenv("ARM_CLIENT_SECRET")
	require.NotEmpty(t, clientSecret, "ARM_CLIENT_SECRET environment variable must be set")

	location := os.Getenv("ARM_LOCATION")
	if location == "" {
		location = "West Europe"
	}

	uniqueID := strings.ToLower(random.UniqueId())

	return &TestConfig{
		SubscriptionID: subscriptionID,
		TenantID:      tenantID,
		ClientID:      clientID,
		ClientSecret:  clientSecret,
		Location:      location,
		ResourceGroup: fmt.Sprintf("rg-test-vnet-%s", uniqueID),
		UniqueID:      uniqueID,
	}
}

// GetAzureCredential returns Azure credentials for SDK calls
func GetAzureCredential(t *testing.T) azcore.TokenCredential {
	cred, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to create Azure credential")
	return cred
}

// WaitForResourceDeletion waits for a resource to be deleted
func WaitForResourceDeletion(ctx context.Context, checkFunc func() (bool, error), timeout time.Duration) error {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	timeoutCh := time.After(timeout)

	for {
		select {
		case <-timeoutCh:
			return fmt.Errorf("timeout waiting for resource deletion")
		case <-ticker.C:
			exists, err := checkFunc()
			if err != nil {
				return fmt.Errorf("error checking resource existence: %w", err)
			}
			if !exists {
				return nil
			}
		}
	}
}

// GenerateResourceName generates a unique resource name for testing
func GenerateResourceName(prefix string, uniqueID string) string {
	// Ensure the name meets Azure naming requirements
	name := fmt.Sprintf("%s-%s", prefix, uniqueID)
	// Ensure length limits for Virtual Network (max 80 characters)
	if len(name) > 80 {
		name = name[:80]
	}
	return strings.ToLower(name)
}

// GenerateVirtualNetworkName generates a unique Virtual Network name for testing
func GenerateVirtualNetworkName(uniqueID string) string {
	return GenerateResourceName("vnet-test", uniqueID)
}

// ValidateVirtualNetworkName validates that a Virtual Network name meets Azure requirements
func ValidateVirtualNetworkName(name string) error {
	if len(name) < 2 || len(name) > 80 {
		return fmt.Errorf("Virtual Network name must be between 2 and 80 characters")
	}
	
	// Must start and end with alphanumeric character
	if !((name[0] >= 'a' && name[0] <= 'z') || (name[0] >= 'A' && name[0] <= 'Z') || (name[0] >= '0' && name[0] <= '9')) {
		return fmt.Errorf("Virtual Network name must start with alphanumeric character")
	}
	
	lastChar := name[len(name)-1]
	if !((lastChar >= 'a' && lastChar <= 'z') || (lastChar >= 'A' && lastChar <= 'Z') || (lastChar >= '0' && lastChar <= '9')) {
		return fmt.Errorf("Virtual Network name must end with alphanumeric character")
	}
	
	// Can contain alphanumeric characters, hyphens, periods, and underscores
	for _, char := range name {
		if !((char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z') || (char >= '0' && char <= '9') || char == '-' || char == '.' || char == '_') {
			return fmt.Errorf("Virtual Network name can only contain alphanumeric characters, hyphens, periods, and underscores")
		}
	}
	
	return nil
}

// ValidateAddressSpace validates that address spaces are valid CIDR blocks
func ValidateAddressSpace(addressSpaces []string) error {
	if len(addressSpaces) == 0 {
		return fmt.Errorf("at least one address space must be provided")
	}
	
	for _, addressSpace := range addressSpaces {
		if !strings.Contains(addressSpace, "/") {
			return fmt.Errorf("address space %s is not a valid CIDR block", addressSpace)
		}
		
		// Basic CIDR validation - could be enhanced with more sophisticated checks
		parts := strings.Split(addressSpace, "/")
		if len(parts) != 2 {
			return fmt.Errorf("address space %s is not a valid CIDR block", addressSpace)
		}
	}
	
	return nil
}

// GetVirtualNetwork retrieves a virtual network from Azure
func GetVirtualNetwork(t *testing.T, virtualNetworkName, resourceGroupName, subscriptionID string) *armnetwork.VirtualNetwork {
	if subscriptionID == "" {
		subscriptionID = os.Getenv("ARM_SUBSCRIPTION_ID")
		require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID must be set")
	}

	cred := GetAzureCredential(t)
	client, err := armnetwork.NewVirtualNetworksClient(subscriptionID, cred, nil)
	require.NoError(t, err, "Failed to create virtual networks client")

	ctx := context.Background()
	resp, err := client.Get(ctx, resourceGroupName, virtualNetworkName, nil)
	require.NoError(t, err, "Failed to get virtual network")

	return &resp.VirtualNetwork
}

// getTerraformOptions returns terraform options for test runs
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	// Generate unique random suffix for resource naming
	randomSuffix := generateRandomSuffix()
	
	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"random_suffix": randomSuffix,
		},
		RetryableTerraformErrors: map[string]string{
			".*": "Terraform operation failed",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}

// generateRandomSuffix generates a unique suffix for test resources
func generateRandomSuffix() string {
	// Use combination of random string and timestamp for uniqueness
	timestamp := time.Now().Format("0102") // MMDD format
	randomStr := strings.ToLower(random.UniqueId())
	
	// Limit the random string length to ensure total suffix is manageable
	if len(randomStr) > 5 {
		randomStr = randomStr[:5]
	}
	
	return fmt.Sprintf("%s%s", randomStr, timestamp)
}