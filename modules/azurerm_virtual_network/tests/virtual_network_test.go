package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestVirtualNetworkModule runs all Virtual Network module tests
func TestVirtualNetworkModule(t *testing.T) {
	t.Parallel()

	// Run subtests
	t.Run("Basic", testVirtualNetworkBasic)
	t.Run("Complete", testVirtualNetworkComplete)
	t.Run("Secure", testVirtualNetworkSecure)
	t.Run("Network", testVirtualNetworkWithPeering)
	t.Run("PrivateEndpoint", testVirtualNetworkPrivateEndpoint)
}

func testVirtualNetworkBasic(t *testing.T) {
	t.Parallel()

	// Copy fixture to temp folder
	fixtureFolder := "./fixtures/basic"
	tempFolder := test_structure.CopyTerraformFolderToTemp(t, "../", fixtureFolder)

	// Generate random suffix
	randomSuffix := random.UniqueId()

	terraformOptions := &terraform.Options{
		TerraformDir: tempFolder,
		Vars: map[string]interface{}{
			"random_suffix": randomSuffix,
		},
		NoColor: true,
	}

	// Save options for cleanup
	test_structure.SaveTerraformOptions(t, tempFolder, terraformOptions)

	// Cleanup
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
		terraform.Destroy(t, terraformOptions)
	})

	// Deploy
	test_structure.RunTestStage(t, "deploy", func() {
		terraform.InitAndApply(t, terraformOptions)
	})

	// Validate
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
		validateBasicVirtualNetwork(t, terraformOptions)
	})
}

func testVirtualNetworkComplete(t *testing.T) {
	t.Parallel()

	fixtureFolder := "./fixtures/complete"
	tempFolder := test_structure.CopyTerraformFolderToTemp(t, "../", fixtureFolder)

	randomSuffix := random.UniqueId()

	terraformOptions := &terraform.Options{
		TerraformDir: tempFolder,
		Vars: map[string]interface{}{
			"random_suffix": randomSuffix,
		},
		NoColor: true,
	}

	test_structure.SaveTerraformOptions(t, tempFolder, terraformOptions)

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
		validateCompleteVirtualNetwork(t, terraformOptions)
	})
}

func testVirtualNetworkSecure(t *testing.T) {
	t.Parallel()

	fixtureFolder := "./fixtures/secure"
	tempFolder := test_structure.CopyTerraformFolderToTemp(t, "../", fixtureFolder)

	randomSuffix := random.UniqueId()

	terraformOptions := &terraform.Options{
		TerraformDir: tempFolder,
		Vars: map[string]interface{}{
			"random_suffix": randomSuffix,
		},
		NoColor: true,
	}

	test_structure.SaveTerraformOptions(t, tempFolder, terraformOptions)

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
		validateSecureVirtualNetwork(t, terraformOptions)
	})
}

func testVirtualNetworkWithPeering(t *testing.T) {
	t.Parallel()

	fixtureFolder := "./fixtures/network"
	tempFolder := test_structure.CopyTerraformFolderToTemp(t, "../", fixtureFolder)

	randomSuffix := random.UniqueId()

	terraformOptions := &terraform.Options{
		TerraformDir: tempFolder,
		Vars: map[string]interface{}{
			"random_suffix": randomSuffix,
		},
		NoColor: true,
	}

	test_structure.SaveTerraformOptions(t, tempFolder, terraformOptions)

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
		validateNetworkPeering(t, terraformOptions)
	})
}

func testVirtualNetworkPrivateEndpoint(t *testing.T) {
	t.Parallel()

	fixtureFolder := "./fixtures/private_endpoint"
	tempFolder := test_structure.CopyTerraformFolderToTemp(t, "../", fixtureFolder)

	randomSuffix := random.UniqueId()

	terraformOptions := &terraform.Options{
		TerraformDir: tempFolder,
		Vars: map[string]interface{}{
			"random_suffix": randomSuffix,
		},
		NoColor: true,
	}

	test_structure.SaveTerraformOptions(t, tempFolder, terraformOptions)

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
		validatePrivateEndpoint(t, terraformOptions)
	})
}

// Validation functions
func validateBasicVirtualNetwork(t *testing.T, terraformOptions *terraform.Options) {
	// Get outputs
	vnetID := terraform.Output(t, terraformOptions, "virtual_network_id")
	vnetName := terraform.Output(t, terraformOptions, "virtual_network_name")
	addressSpace := terraform.OutputList(t, terraformOptions, "virtual_network_address_space")
	vnetGUID := terraform.Output(t, terraformOptions, "virtual_network_guid")

	// Assertions
	assert.NotEmpty(t, vnetID)
	assert.Contains(t, vnetName, "vnet-")
	assert.NotEmpty(t, addressSpace)
	assert.Len(t, addressSpace, 1)
	assert.Equal(t, "10.0.0.0/16", addressSpace[0])
	assert.NotEmpty(t, vnetGUID)
}

func validateCompleteVirtualNetwork(t *testing.T, terraformOptions *terraform.Options) {
	// Get outputs
	vnetID := terraform.Output(t, terraformOptions, "virtual_network_id")
	vnetName := terraform.Output(t, terraformOptions, "virtual_network_name")
	peerings := terraform.Output(t, terraformOptions, "virtual_network_peerings")
	dnsLinks := terraform.Output(t, terraformOptions, "virtual_network_dns_links")
	diagnosticSetting := terraform.Output(t, terraformOptions, "virtual_network_diagnostic_setting")

	// Assertions
	assert.NotEmpty(t, vnetID)
	assert.Contains(t, vnetName, "vnet-")
	assert.NotEmpty(t, peerings)
	assert.NotEmpty(t, dnsLinks)
	assert.NotEmpty(t, diagnosticSetting)
}

func validateSecureVirtualNetwork(t *testing.T, terraformOptions *terraform.Options) {
	// Get outputs
	vnetID := terraform.Output(t, terraformOptions, "virtual_network_id")
	ddosProtection := terraform.Output(t, terraformOptions, "virtual_network_ddos_protection")
	flowLog := terraform.Output(t, terraformOptions, "virtual_network_flow_log")
	securityConfig := terraform.OutputMap(t, terraformOptions, "virtual_network_security_configuration")

	// Assertions
	assert.NotEmpty(t, vnetID)
	assert.NotEmpty(t, ddosProtection)
	assert.NotEmpty(t, flowLog)
	assert.Equal(t, "true", securityConfig["ddos_protection_enabled"])
	assert.Equal(t, "true", securityConfig["flow_logs_enabled"])
	assert.Equal(t, "true", securityConfig["encryption_enabled"])
	assert.Equal(t, "true", securityConfig["monitoring_enabled"])
}

func validateNetworkPeering(t *testing.T, terraformOptions *terraform.Options) {
	// Get outputs
	hubVnetID := terraform.Output(t, terraformOptions, "hub_vnet_id")
	spokeVnetID := terraform.Output(t, terraformOptions, "spoke_vnet_id")
	peeringHubToSpoke := terraform.Output(t, terraformOptions, "peering_hub_to_spoke_id")
	peeringSpokeToHub := terraform.Output(t, terraformOptions, "peering_spoke_to_hub_id")

	// Assertions
	assert.NotEmpty(t, hubVnetID)
	assert.NotEmpty(t, spokeVnetID)
	assert.NotEmpty(t, peeringHubToSpoke)
	assert.NotEmpty(t, peeringSpokeToHub)
	assert.NotEqual(t, hubVnetID, spokeVnetID)
}

func validatePrivateEndpoint(t *testing.T, terraformOptions *terraform.Options) {
	// Get outputs
	vnetID := terraform.Output(t, terraformOptions, "virtual_network_id")
	privateEndpointSubnetID := terraform.Output(t, terraformOptions, "private_endpoint_subnet_id")

	// Assertions
	assert.NotEmpty(t, vnetID)
	assert.NotEmpty(t, privateEndpointSubnetID)
	assert.Contains(t, privateEndpointSubnetID, "/subnets/")
	assert.Contains(t, privateEndpointSubnetID, vnetID)
}

// Helper function to get Terraform options with custom variables
func getTerraformOptionsWithVars(t testing.TB, fixtureFolder string, vars map[string]interface{}) *terraform.Options {
	// Set default random suffix if not provided
	if _, ok := vars["random_suffix"]; !ok {
		vars["random_suffix"] = fmt.Sprintf("%d", random.Random(10000, 99999))
	}

	return &terraform.Options{
		TerraformDir: fixtureFolder,
		Vars:         vars,
		NoColor:      true,
	}
}