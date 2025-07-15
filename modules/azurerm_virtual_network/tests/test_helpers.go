package test

import (
	"context"
	"fmt"
	"os"
	"regexp"
	"strings"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork/v5"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
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

// getTerraformOptionsWithVars returns terraform options with custom variables
func getTerraformOptionsWithVars(t testing.TB, terraformDir string, vars map[string]interface{}) *terraform.Options {
	// Get base options
	options := getTerraformOptions(t, terraformDir)
	
	// Merge custom vars with existing ones
	for k, v := range vars {
		options.Vars[k] = v
	}
	
	return options
}

// generateRandomSuffix generates a unique suffix for test resources
func generateRandomSuffix() string {
	// Generate a random string with only lowercase letters and numbers
	randomStr := strings.ToLower(random.UniqueId())
	
	// Remove any non-alphanumeric characters and ensure only lowercase
	cleanStr := ""
	for _, char := range randomStr {
		if (char >= 'a' && char <= 'z') || (char >= '0' && char <= '9') {
			cleanStr += string(char)
		}
	}
	
	// Ensure we have at least 6 characters
	if len(cleanStr) < 6 {
		// Generate another random string and process it the same way
		additionalStr := strings.ToLower(random.UniqueId())
		for _, char := range additionalStr {
			if len(cleanStr) >= 6 {
				break
			}
			if (char >= 'a' && char <= 'z') || (char >= '0' && char <= '9') {
				cleanStr += string(char)
			}
		}
	}
	
	// Limit to 8 characters to leave room for prefixes
	if len(cleanStr) > 8 {
		cleanStr = cleanStr[:8]
	}
	
	return cleanStr
}

// stripAnsiCodes removes ANSI color codes from text
func stripAnsiCodes(text string) string {
	// Regex pattern to match ANSI escape codes
	ansiRegex := regexp.MustCompile(`\x1b\[[0-9;]*m`)
	return ansiRegex.ReplaceAllString(text, "")
}

// VirtualNetworkHelper provides helper functions for Virtual Network tests
type VirtualNetworkHelper struct {
	client         *armnetwork.VirtualNetworksClient
	subscriptionID string
}

// NewVirtualNetworkHelper creates a new VirtualNetworkHelper instance
func NewVirtualNetworkHelper(t *testing.T) *VirtualNetworkHelper {
	config := GetTestConfig(t)
	cred := GetAzureCredential(t)
	
	client, err := armnetwork.NewVirtualNetworksClient(config.SubscriptionID, cred, nil)
	require.NoError(t, err, "Failed to create Virtual Networks client")
	
	return &VirtualNetworkHelper{
		client:         client,
		subscriptionID: config.SubscriptionID,
	}
}

// GetVirtualNetworkProperties retrieves detailed virtual network properties
func (h *VirtualNetworkHelper) GetVirtualNetworkProperties(t *testing.T, vnetName, resourceGroupName string) armnetwork.VirtualNetwork {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()
	
	resp, err := h.client.Get(ctx, resourceGroupName, vnetName, &armnetwork.VirtualNetworksClientGetOptions{})
	require.NoError(t, err, "Failed to get virtual network properties")
	
	return resp.VirtualNetwork
}

// WaitForVirtualNetworkReady waits for virtual network to be in a ready state
func (h *VirtualNetworkHelper) WaitForVirtualNetworkReady(t *testing.T, vnetName, resourceGroupName string) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Minute)
	defer cancel()
	
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-ctx.Done():
			t.Fatal("Timeout waiting for virtual network to be ready")
		case <-ticker.C:
			vnet, err := h.client.Get(ctx, resourceGroupName, vnetName, &armnetwork.VirtualNetworksClientGetOptions{})
			if err == nil && vnet.Properties.ProvisioningState != nil && 
			   *vnet.Properties.ProvisioningState == armnetwork.ProvisioningStateSucceeded {
				return
			}
		}
	}
}

// ValidateSubnets validates subnet configuration
func (h *VirtualNetworkHelper) ValidateSubnets(t *testing.T, vnet armnetwork.VirtualNetwork, expectedSubnetCount int) {
	require.NotNil(t, vnet.Properties.Subnets, "Subnets should not be nil")
	assert.GreaterOrEqual(t, len(vnet.Properties.Subnets), expectedSubnetCount, 
		"VNet should have at least %d subnets", expectedSubnetCount)
	
	for _, subnet := range vnet.Properties.Subnets {
		assert.NotNil(t, subnet.Name, "Subnet name should not be nil")
		assert.NotNil(t, subnet.Properties, "Subnet properties should not be nil")
		assert.NotNil(t, subnet.Properties.AddressPrefix, "Subnet address prefix should not be nil")
		assert.Equal(t, armnetwork.ProvisioningStateSucceeded, *subnet.Properties.ProvisioningState,
			"Subnet %s should be successfully provisioned", *subnet.Name)
	}
}