package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestVirtualNetworkFullIntegration tests all features working together
func TestVirtualNetworkFullIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_virtual_network/tests/fixtures/complete")
	
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
}

// validateCoreFeatures validates core VNet features
func validateCoreFeatures(t *testing.T, testFolder string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
	
	// Core outputs
	vnetID := terraform.Output(t, terraformOptions, "virtual_network_id")
	vnetName := terraform.Output(t, terraformOptions, "virtual_network_name")
	addressSpace := terraform.OutputList(t, terraformOptions, "virtual_network_address_space")
	
	// Assertions
	assert.NotEmpty(t, vnetID)
	assert.NotEmpty(t, vnetName)
	assert.NotEmpty(t, addressSpace)
}

// validateSecurityFeatures validates security-related features
func validateSecurityFeatures(t *testing.T, testFolder string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
	helper := NewVirtualNetworkHelper(t)
	
	// Get resource details from outputs
	vnetName := terraform.Output(t, terraformOptions, "virtual_network_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	
	// Get VNet properties from Azure
	vnet := helper.GetVirtualNetworkProperties(t, vnetName, resourceGroupName)
	
	// Security validations
	if vnet.Properties.DdosProtectionPlan != nil && vnet.Properties.DdosProtectionPlan.ID != nil {
		assert.NotEmpty(t, *vnet.Properties.DdosProtectionPlan.ID, "DDoS protection plan should be configured if enabled")
	}
	
	// Check if DDoS protection is enabled
	ddosEnabled := vnet.Properties.EnableDdosProtection != nil && *vnet.Properties.EnableDdosProtection
	assert.False(t, ddosEnabled, "DDoS protection should be disabled by default")
}

// validateNetworkFeatures validates network-related features
func validateNetworkFeatures(t *testing.T, testFolder string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
	helper := NewVirtualNetworkHelper(t)
	
	// Get resource details from outputs
	vnetName := terraform.Output(t, terraformOptions, "virtual_network_name")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	
	// Get VNet properties from Azure
	vnet := helper.GetVirtualNetworkProperties(t, vnetName, resourceGroupName)
	
	// Validate subnets
	assert.NotNil(t, vnet.Properties.Subnets, "Subnets should not be nil")
	if vnet.Properties.Subnets != nil && len(vnet.Properties.Subnets) > 0 {
		t.Logf("Found %d subnets in VNet", len(vnet.Properties.Subnets))
		for _, subnet := range vnet.Properties.Subnets {
			assert.NotNil(t, subnet.Name, "Subnet name should not be nil")
			assert.NotNil(t, subnet.Properties.AddressPrefix, "Subnet address prefix should not be nil")
		}
	}
	
	// Validate DNS servers
	if vnet.Properties.DhcpOptions != nil && vnet.Properties.DhcpOptions.DNSServers != nil {
		t.Logf("DNS servers configured: %v", vnet.Properties.DhcpOptions.DNSServers)
	}
}

// TestVirtualNetworkWithPeering tests Virtual Network with peering configuration
func TestVirtualNetworkWithPeering(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_virtual_network/tests/fixtures/network")
	
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

	// Validate outputs
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		
		// Test outputs
		hubVnetID := terraform.Output(t, terraformOptions, "hub_vnet_id")
		spokeVnetID := terraform.Output(t, terraformOptions, "spoke_vnet_id")
		peeringHubToSpoke := terraform.Output(t, terraformOptions, "peering_hub_to_spoke_id")
		peeringSpokeToHub := terraform.Output(t, terraformOptions, "peering_spoke_to_hub_id")

		// Assertions
		assert.NotEmpty(t, hubVnetID)
		assert.NotEmpty(t, spokeVnetID)
		assert.NotEmpty(t, peeringHubToSpoke)
		assert.NotEmpty(t, peeringSpokeToHub)
	})
}

// TestVirtualNetworkPrivateEndpoint tests Virtual Network with private endpoint support
func TestVirtualNetworkPrivateEndpoint(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_virtual_network/tests/fixtures/private_endpoint")
	
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

	// Validate outputs
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		
		// Test outputs
		vnetID := terraform.Output(t, terraformOptions, "virtual_network_id")
		privateEndpointSubnetID := terraform.Output(t, terraformOptions, "private_endpoint_subnet_id")
		
		// Assertions
		assert.NotEmpty(t, vnetID)
		assert.NotEmpty(t, privateEndpointSubnetID)
		assert.Contains(t, privateEndpointSubnetID, "/subnets/snet-private-endpoints")
	})
}

// TestVirtualNetworkDNS tests Virtual Network with custom DNS configuration
func TestVirtualNetworkDNS(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_virtual_network/tests/fixtures/complete")
	
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

	// Validate outputs
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		
		// Test outputs - expect DNS servers to be set
		dnsServers := terraform.OutputList(t, terraformOptions, "dns_servers")
		
		// Assertions
		assert.Len(t, dnsServers, 2)
		assert.Contains(t, dnsServers, "10.0.1.4")
		assert.Contains(t, dnsServers, "10.0.1.5")
	})
}

// TestVirtualNetworkFlowLogs tests Virtual Network with flow logs enabled
func TestVirtualNetworkFlowLogs(t *testing.T) {
	t.Skip("Skipping flow logs test - NSG flow logs are deprecated and being blocked by Azure")
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_virtual_network/tests/fixtures/flow_logs")
	
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

	// Validate outputs
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		
		// Test outputs
		flowLogInfo := terraform.Output(t, terraformOptions, "virtual_network_flow_log")
		
		// Assertions
		assert.NotEmpty(t, flowLogInfo)
		assert.Contains(t, flowLogInfo, "enabled")
	})
}

// TestVirtualNetworkValidationRules tests the module's input validation rules
func TestVirtualNetworkValidationRules(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping validation tests in short mode")
	}
	t.Parallel()

	testCases := []struct {
		name          string
		fixturePath   string
		expectError   bool
		errorContains string
	}{
		{
			name:          "InvalidNameShort",
			fixturePath:   "azurerm_virtual_network/tests/fixtures/negative/invalid_name_short",
			expectError:   true,
			errorContains: "Virtual Network name must be 2-80 characters long",
		},
		{
			name:          "InvalidNameLong",
			fixturePath:   "azurerm_virtual_network/tests/fixtures/negative/invalid_name_long",
			expectError:   true,
			errorContains: "Virtual Network name must be 2-80 characters long",
		},
		{
			name:          "InvalidNameChars",
			fixturePath:   "azurerm_virtual_network/tests/fixtures/negative/invalid_name_chars",
			expectError:   true,
			errorContains: "Virtual Network name must be 2-80 characters long",
		},
		{
			name:          "EmptyAddressSpace",
			fixturePath:   "azurerm_virtual_network/tests/fixtures/negative/empty_address_space",
			expectError:   true,
			errorContains: "At least one address space must be provided",
		},
	}

	for _, tc := range testCases {
		tc := tc // capture range variable
		t.Run(tc.name, func(t *testing.T) {
			testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", tc.fixturePath)
			
			// Use minimal terraform options for negative tests (no variables)
			terraformOptions := &terraform.Options{
				TerraformDir: testFolder,
				NoColor:      true,
			}

			if tc.expectError {
				// This should fail during plan/apply
				_, err := terraform.InitAndPlanE(t, terraformOptions)
				require.Error(t, err)
				assert.Contains(t, err.Error(), tc.errorContains)
			} else {
				defer terraform.Destroy(t, terraformOptions)
				terraform.InitAndApply(t, terraformOptions)
			}
		})
	}
}
