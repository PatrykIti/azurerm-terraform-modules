package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestVirtualNetworkBasic(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions(t, "../fixtures/basic")

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Test outputs
	outputID := terraform.Output(t, terraformOptions, "virtual_network_id")
	outputName := terraform.Output(t, terraformOptions, "virtual_network_name")
	outputAddressSpace := terraform.Output(t, terraformOptions, "virtual_network_address_space")
	outputGUID := terraform.Output(t, terraformOptions, "virtual_network_guid")

	// Assertions
	assert.NotEmpty(t, outputID)
	assert.Contains(t, outputName, "vnet-dpc-bas-")
	assert.NotEmpty(t, outputAddressSpace)
	assert.NotEmpty(t, outputGUID)

	// Get actual resource names from outputs
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	virtualNetworkName := terraform.Output(t, terraformOptions, "virtual_network_name")
	location := terraform.Output(t, terraformOptions, "location")

	// Verify the Virtual Network exists in Azure
	subscriptionID := ""
	virtualNetwork := GetVirtualNetwork(t, virtualNetworkName, resourceGroupName, subscriptionID)
	assert.Equal(t, virtualNetworkName, *virtualNetwork.Name)
	assert.Contains(t, strings.ToLower(*virtualNetwork.Location), strings.ToLower(location))
	assert.NotEmpty(t, virtualNetwork.Properties.AddressSpace.AddressPrefixes)
}

func TestVirtualNetworkComplete(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions(t, "../fixtures/complete")

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Test outputs
	outputID := terraform.Output(t, terraformOptions, "virtual_network_id")
	outputName := terraform.Output(t, terraformOptions, "virtual_network_name")
	outputAddressSpace := terraform.Output(t, terraformOptions, "virtual_network_address_space")
	outputPeerings := terraform.Output(t, terraformOptions, "virtual_network_peerings")
	outputDNSLinks := terraform.Output(t, terraformOptions, "virtual_network_dns_links")

	// Assertions
	assert.NotEmpty(t, outputID)
	assert.Contains(t, outputName, "vnet-dpc-cmp-")
	assert.NotEmpty(t, outputAddressSpace)
	assert.NotEmpty(t, outputPeerings)
	assert.NotEmpty(t, outputDNSLinks)

	// Get actual resource names from outputs
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	virtualNetworkName := terraform.Output(t, terraformOptions, "virtual_network_name")
	location := terraform.Output(t, terraformOptions, "location")

	// Verify the Virtual Network exists in Azure with expected configuration
	subscriptionID := ""
	virtualNetwork := GetVirtualNetwork(t, virtualNetworkName, resourceGroupName, subscriptionID)
	assert.Equal(t, virtualNetworkName, *virtualNetwork.Name)
	assert.Contains(t, strings.ToLower(*virtualNetwork.Location), strings.ToLower(location))
	
	// Verify multiple address spaces
	require.NotNil(t, virtualNetwork.Properties.AddressSpace)
	require.NotNil(t, virtualNetwork.Properties.AddressSpace.AddressPrefixes)
	assert.GreaterOrEqual(t, len(virtualNetwork.Properties.AddressSpace.AddressPrefixes), 2)
	
	// Verify DNS servers configuration
	require.NotNil(t, virtualNetwork.Properties.DhcpOptions)
	require.NotNil(t, virtualNetwork.Properties.DhcpOptions.DNSServers)
	assert.GreaterOrEqual(t, len(virtualNetwork.Properties.DhcpOptions.DNSServers), 2)
}

func TestVirtualNetworkSecure(t *testing.T) {
	t.Parallel()

	terraformOptions := getTerraformOptions(t, "../fixtures/secure")

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Test outputs
	outputID := terraform.Output(t, terraformOptions, "virtual_network_id")
	outputName := terraform.Output(t, terraformOptions, "virtual_network_name")
	outputDDosProtection := terraform.Output(t, terraformOptions, "virtual_network_ddos_protection")
	outputFlowLog := terraform.Output(t, terraformOptions, "virtual_network_flow_log")

	// Assertions
	assert.NotEmpty(t, outputID)
	assert.Contains(t, outputName, "vnet-dpc-sec-")
	assert.NotEmpty(t, outputDDosProtection)
	assert.NotEmpty(t, outputFlowLog)

	// Get actual resource names from outputs
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	virtualNetworkName := terraform.Output(t, terraformOptions, "virtual_network_name")
	location := terraform.Output(t, terraformOptions, "location")

	// Verify the Virtual Network exists in Azure with security features
	subscriptionID := ""
	virtualNetwork := GetVirtualNetwork(t, virtualNetworkName, resourceGroupName, subscriptionID)
	assert.Equal(t, virtualNetworkName, *virtualNetwork.Name)
	assert.Contains(t, strings.ToLower(*virtualNetwork.Location), strings.ToLower(location))
	
	// Verify DDoS protection is enabled
	require.NotNil(t, virtualNetwork.Properties.DdosProtectionPlan)
	assert.True(t, *virtualNetwork.Properties.EnableDdosProtection)
}

func TestVirtualNetworkValidation(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		addressSpace  []string
		expectedError string
	}{
		{
			name:          "Valid single address space",
			addressSpace:  []string{"10.0.0.0/16"},
			expectedError: "",
		},
		{
			name:          "Valid multiple address spaces",
			addressSpace:  []string{"10.0.0.0/16", "10.1.0.0/16"},
			expectedError: "",
		},
		{
			name:          "Empty address space",
			addressSpace:  []string{},
			expectedError: "At least one address space must be provided",
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			terraformOptions := getTerraformOptions(t, "../fixtures/basic")
			terraformOptions.Vars["address_space"] = tc.addressSpace

			if tc.expectedError != "" {
				_, err := terraform.InitAndPlanE(t, terraformOptions)
				assert.Error(t, err)
				assert.Contains(t, err.Error(), tc.expectedError)
			} else {
				defer terraform.Destroy(t, terraformOptions)
				terraform.InitAndApply(t, terraformOptions)
				
				outputID := terraform.Output(t, terraformOptions, "virtual_network_id")
				assert.NotEmpty(t, outputID)
			}
		})
	}
}

func TestVirtualNetworkNaming(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		vnetName      string
		expectedError bool
	}{
		{
			name:          "Valid name with hyphens",
			vnetName:      "vnet-test-example",
			expectedError: false,
		},
		{
			name:          "Valid name with underscores",
			vnetName:      "vnet_test_example",
			expectedError: false,
		},
		{
			name:          "Valid name with periods",
			vnetName:      "vnet.test.example",
			expectedError: false,
		},
		{
			name:          "Invalid name starting with hyphen",
			vnetName:      "-vnet-test",
			expectedError: true,
		},
		{
			name:          "Invalid name ending with hyphen",
			vnetName:      "vnet-test-",
			expectedError: true,
		},
		{
			name:          "Invalid name too long",
			vnetName:      strings.Repeat("a", 81),
			expectedError: true,
		},
		{
			name:          "Invalid name too short",
			vnetName:      "a",
			expectedError: true,
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			uniqueID := random.UniqueId()
			resourceGroupName := fmt.Sprintf("rg-vnet-naming-test-%s", uniqueID)

			terraformOptions := &terraform.Options{
				TerraformDir: "../fixtures/basic",
				Vars: map[string]interface{}{
					"resource_group_name":  resourceGroupName,
					"virtual_network_name": tc.vnetName,
					"address_space":        []string{"10.0.0.0/16"},
				},
			}

			if tc.expectedError {
				_, err := terraform.InitAndPlanE(t, terraformOptions)
				assert.Error(t, err)
			} else {
				defer terraform.Destroy(t, terraformOptions)
				terraform.InitAndApply(t, terraformOptions)
				
				outputName := terraform.Output(t, terraformOptions, "virtual_network_name")
				assert.Equal(t, tc.vnetName, outputName)
			}
		})
	}
}

