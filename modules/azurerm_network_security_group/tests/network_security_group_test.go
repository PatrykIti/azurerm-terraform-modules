package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestSimpleNetworkSecurityGroup tests the simple NSG fixture.
func TestSimpleNetworkSecurityGroup(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_network_security_group/tests/fixtures/simple")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		nsgName := terraform.Output(t, terraformOptions, "name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		helper := NewNetworkSecurityGroupHelper(t)
		nsg := helper.GetNsgProperties(t, resourceGroupName, nsgName)

		assert.Equal(t, nsgName, *nsg.Name, "NSG name should match the output.")
	})
}

// TestCompleteNetworkSecurityGroup tests the complete NSG fixture.
func TestCompleteNetworkSecurityGroup(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_network_security_group/tests/fixtures/complete")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		nsgName := terraform.Output(t, terraformOptions, "name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		flowLogID := terraform.Output(t, terraformOptions, "flow_log_id")

		helper := NewNetworkSecurityGroupHelper(t)
		nsg := helper.GetNsgProperties(t, resourceGroupName, nsgName)

		assert.Equal(t, nsgName, *nsg.Name, "NSG name should match the output.")
		assert.NotEmpty(t, flowLogID, "Flow Log ID should not be empty.")
		// The fixture defines 2 custom rules. Azure adds default rules.
		// We validate that our 2 custom rules are present.
		helper.ValidateNsgSecurityRules(t, nsg, 2)
	})
}

// TestNetworkNetworkSecurityGroup tests the network fixture with advanced networking rules.
func TestNetworkNetworkSecurityGroup(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_network_security_group/tests/fixtures/network")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		nsgName := terraform.Output(t, terraformOptions, "name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		helper := NewNetworkSecurityGroupHelper(t)
		nsg := helper.GetNsgProperties(t, resourceGroupName, nsgName)

		assert.Equal(t, nsgName, *nsg.Name, "NSG name should match the output.")
		// The network fixture defines 1 custom rule with multiple source prefixes and destination port ranges
		helper.ValidateNsgSecurityRules(t, nsg, 1)
	})
}

// TestNetworkSecurityGroupValidationRules tests the input validation rules.
func TestNetworkSecurityGroupValidationRules(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_network_security_group/tests/fixtures/negative")

	terraformOptions := &terraform.Options{
		TerraformDir: testFolder,
		Vars: map[string]interface{}{
			"random_suffix": "neg",
		},
	}

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err, "Plan should fail for invalid input.")
	assert.Contains(t, err.Error(), "Security rule priority must be between 100 and 4096", "Error message should indicate invalid priority.")
}