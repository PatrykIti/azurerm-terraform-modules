package test

import (
	"context"
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork"
	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestSubnetModule runs all subnet module tests
func TestSubnetModule(t *testing.T) {
	t.Parallel()

	// Run subtests
	t.Run("Basic", TestSubnetBasic)
	t.Run("Complete", TestSubnetComplete)
	t.Run("Secure", TestSubnetSecure)
	t.Run("PrivateEndpoint", TestSubnetPrivateEndpoint)
}

// TestSubnetBasic tests basic subnet creation
func TestSubnetBasic(t *testing.T) {
	t.Parallel()

	// Generate a random suffix for naming
	uniqueID := strings.ToLower(random.UniqueId())
	resourceGroupName := fmt.Sprintf("rg-subnet-test-%s", uniqueID)
	vnetName := fmt.Sprintf("vnet-test-%s", uniqueID)
	subnetName := fmt.Sprintf("subnet-test-%s", uniqueID)

	// Configure Terraform options
	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/basic",
		Vars: map[string]interface{}{
			"name_suffix": uniqueID,
		},
		NoColor: true,
	}

	// Clean up resources after test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	subnetID := terraform.Output(t, terraformOptions, "subnet_id")
	actualSubnetName := terraform.Output(t, terraformOptions, "subnet_name")
	actualRGName := terraform.Output(t, terraformOptions, "resource_group_name")
	actualVNetName := terraform.Output(t, terraformOptions, "virtual_network_name")
	addressPrefixes := terraform.OutputList(t, terraformOptions, "subnet_address_prefixes")

	// Verify outputs
	assert.NotEmpty(t, subnetID)
	assert.Contains(t, actualSubnetName, "subnet-basic")
	assert.Contains(t, actualRGName, "rg-subnet-basic")
	assert.Contains(t, actualVNetName, "vnet-basic")
	assert.Equal(t, 1, len(addressPrefixes))
	assert.Equal(t, "10.0.1.0/24", addressPrefixes[0])

	// Verify the subnet exists in Azure
	subscriptionID := getRequiredEnvVar(t, "ARM_SUBSCRIPTION_ID")
	exists := azure.SubnetExists(t, actualSubnetName, actualVNetName, actualRGName, subscriptionID)
	assert.True(t, exists, "Subnet should exist in Azure")
}

// TestSubnetComplete tests subnet with all features
func TestSubnetComplete(t *testing.T) {
	t.Parallel()

	uniqueID := strings.ToLower(random.UniqueId())

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/complete",
		Vars: map[string]interface{}{
			"name_suffix": uniqueID,
		},
		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	subnetID := terraform.Output(t, terraformOptions, "subnet_id")
	nsgAssociationID := terraform.Output(t, terraformOptions, "nsg_association_id")
	rtAssociationID := terraform.Output(t, terraformOptions, "route_table_association_id")
	serviceEndpoints := terraform.OutputList(t, terraformOptions, "service_endpoints")

	// Verify outputs
	assert.NotEmpty(t, subnetID)
	assert.NotEmpty(t, nsgAssociationID)
	assert.NotEmpty(t, rtAssociationID)
	assert.Greater(t, len(serviceEndpoints), 0)

	// Get subnet details from Azure
	subscriptionID := getRequiredEnvVar(t, "ARM_SUBSCRIPTION_ID")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	vnetName := terraform.Output(t, terraformOptions, "virtual_network_name")
	subnetName := terraform.Output(t, terraformOptions, "subnet_name")

	subnet := getSubnet(t, subscriptionID, resourceGroupName, vnetName, subnetName)
	
	// Verify NSG and Route Table associations
	assert.NotNil(t, subnet.Properties.NetworkSecurityGroup)
	assert.NotNil(t, subnet.Properties.RouteTable)
	
	// Verify service endpoints
	assert.NotNil(t, subnet.Properties.ServiceEndpoints)
	assert.Greater(t, len(subnet.Properties.ServiceEndpoints), 0)
}

// TestSubnetSecure tests secure subnet configuration
func TestSubnetSecure(t *testing.T) {
	t.Parallel()

	uniqueID := strings.ToLower(random.UniqueId())

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/secure",
		Vars: map[string]interface{}{
			"name_suffix": uniqueID,
		},
		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	subnetID := terraform.Output(t, terraformOptions, "subnet_id")
	serviceEndpoints := terraform.OutputList(t, terraformOptions, "service_endpoints")
	privateEndpointPolicies := terraform.Output(t, terraformOptions, "private_endpoint_network_policies")
	privateLinkPolicies := terraform.Output(t, terraformOptions, "private_link_service_network_policies")

	// Verify outputs
	assert.NotEmpty(t, subnetID)
	assert.Greater(t, len(serviceEndpoints), 0)
	assert.Equal(t, "true", privateEndpointPolicies) // Policies should be enabled for security
	assert.Equal(t, "true", privateLinkPolicies)

	// Verify subnet configuration in Azure
	subscriptionID := getRequiredEnvVar(t, "ARM_SUBSCRIPTION_ID")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	vnetName := terraform.Output(t, terraformOptions, "virtual_network_name")
	subnetName := terraform.Output(t, terraformOptions, "subnet_name")

	subnet := getSubnet(t, subscriptionID, resourceGroupName, vnetName, subnetName)

	// Verify security configurations
	assert.NotNil(t, subnet.Properties.NetworkSecurityGroup, "NSG should be associated")
	assert.NotNil(t, subnet.Properties.RouteTable, "Route table should be associated")
	assert.NotNil(t, subnet.Properties.ServiceEndpointPolicies, "Service endpoint policies should be configured")
}

// TestSubnetPrivateEndpoint tests subnet configured for private endpoints
func TestSubnetPrivateEndpoint(t *testing.T) {
	t.Parallel()

	uniqueID := strings.ToLower(random.UniqueId())

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/private-endpoint",
		Vars: map[string]interface{}{
			"name_suffix": uniqueID,
		},
		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	subnetID := terraform.Output(t, terraformOptions, "subnet_id")
	privateEndpointPolicies := terraform.Output(t, terraformOptions, "private_endpoint_network_policies")
	privateLinkPolicies := terraform.Output(t, terraformOptions, "private_link_service_network_policies")

	// Verify outputs - policies should be disabled for private endpoints
	assert.NotEmpty(t, subnetID)
	assert.Equal(t, "false", privateEndpointPolicies, "Private endpoint policies should be disabled")
	assert.Equal(t, "false", privateLinkPolicies, "Private link policies should be disabled")

	// Verify subnet configuration in Azure
	subscriptionID := getRequiredEnvVar(t, "ARM_SUBSCRIPTION_ID")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	vnetName := terraform.Output(t, terraformOptions, "virtual_network_name")
	subnetName := terraform.Output(t, terraformOptions, "subnet_name")

	subnet := getSubnet(t, subscriptionID, resourceGroupName, vnetName, subnetName)

	// Verify the subnet is properly configured for private endpoints
	assert.Equal(t, armnetwork.SubnetPrivateEndpointNetworkPoliciesDisabled, *subnet.Properties.PrivateEndpointNetworkPolicies)
}

// Helper function to get environment variable
func getRequiredEnvVar(t *testing.T, name string) string {
	value := os.Getenv(name)
	require.NotEmpty(t, value, fmt.Sprintf("Required environment variable %s is not set", name))
	return value
}

// Helper function to get subnet from Azure
func getSubnet(t *testing.T, subscriptionID, resourceGroupName, vnetName, subnetName string) *armnetwork.Subnet {
	// Create Azure credential
	cred, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err)

	// Create subnet client
	client, err := armnetwork.NewSubnetsClient(subscriptionID, cred, nil)
	require.NoError(t, err)

	// Get subnet
	ctx := context.Background()
	resp, err := client.Get(ctx, resourceGroupName, vnetName, subnetName, nil)
	require.NoError(t, err)

	return &resp.Subnet
}