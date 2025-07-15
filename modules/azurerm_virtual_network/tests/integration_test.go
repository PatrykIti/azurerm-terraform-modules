package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestVirtualNetworkWithPeering tests Virtual Network with peering configuration
func TestVirtualNetworkWithPeering(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions(t, "./fixtures/network")

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

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
}

// TestVirtualNetworkPrivateEndpoint tests Virtual Network with private endpoint support
func TestVirtualNetworkPrivateEndpoint(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions(t, "./fixtures/private_endpoint")

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Test outputs
	vnetID := terraform.Output(t, terraformOptions, "virtual_network_id")
	privateEndpointSubnetID := terraform.Output(t, terraformOptions, "private_endpoint_subnet_id")
	
	// Assertions
	assert.NotEmpty(t, vnetID)
	assert.NotEmpty(t, privateEndpointSubnetID)
	assert.Contains(t, privateEndpointSubnetID, "/subnets/snet-private-endpoints")
}

// TestVirtualNetworkDNS tests Virtual Network with custom DNS configuration
func TestVirtualNetworkDNS(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions(t, "./fixtures/complete")

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Test outputs - expect DNS servers to be set
	dnsServers := terraform.OutputList(t, terraformOptions, "dns_servers")
	
	// Assertions
	assert.Len(t, dnsServers, 2)
	assert.Contains(t, dnsServers, "10.0.1.4")
	assert.Contains(t, dnsServers, "10.0.1.5")
}

// TestVirtualNetworkFlowLogs tests Virtual Network with flow logs enabled
func TestVirtualNetworkFlowLogs(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions(t, "./fixtures/secure")

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Test outputs
	flowLogInfo := terraform.Output(t, terraformOptions, "virtual_network_flow_log")
	
	// Assertions
	assert.NotEmpty(t, flowLogInfo)
	assert.Contains(t, flowLogInfo, "enabled")
}

// TestVirtualNetworkValidationRules tests the module's input validation rules
func TestVirtualNetworkValidationRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		fixturePath   string
		expectError   bool
		errorContains string
	}{
		{
			name:          "InvalidNameShort",
			fixturePath:   "./fixtures/negative/invalid_name_short",
			expectError:   true,
			errorContains: "Virtual Network name must be 2-80 characters long",
		},
		{
			name:          "InvalidNameLong",
			fixturePath:   "./fixtures/negative/invalid_name_long",
			expectError:   true,
			errorContains: "Virtual Network name must be 2-80 characters long",
		},
		{
			name:          "InvalidNameChars",
			fixturePath:   "./fixtures/negative/invalid_name_chars",
			expectError:   true,
			errorContains: "Virtual Network name must be 2-80 characters long",
		},
		{
			name:          "EmptyAddressSpace",
			fixturePath:   "./fixtures/negative/empty_address_space",
			expectError:   true,
			errorContains: "At least one address space must be provided",
		},
	}

	for _, tc := range testCases {
		tc := tc // capture range variable
		t.Run(tc.name, func(t *testing.T) {
			terraformOptions := getTerraformOptions(t, tc.fixturePath)

			if tc.expectError {
				_, err := terraform.InitAndPlanE(t, terraformOptions)
				assert.Error(t, err)
				if tc.errorContains != "" {
					assert.Contains(t, err.Error(), tc.errorContains)
				}
			} else {
				defer terraform.Destroy(t, terraformOptions)
				terraform.InitAndApply(t, terraformOptions)
			}
		})
	}
}