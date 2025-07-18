package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestNsgLifecycle tests the resource lifecycle (update, idempotency).
func TestNsgLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "modules/azurerm_network_security_group/tests/fixtures/simple")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate_initial", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		nsgName := terraform.Output(t, terraformOptions, "network_security_group_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		helper := NewNetworkSecurityGroupHelper(t)
		nsg := helper.GetNsgProperties(t, resourceGroupName, nsgName)
		assert.NotContains(t, nsg.Tags, "Update")
	})

	test_structure.RunTestStage(t, "update", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraformOptions.Vars["tags"] = map[string]string{
			"Environment": "Test",
			"Update":      "true",
		}
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.Apply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate_update", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		nsgName := terraform.Output(t, terraformOptions, "network_security_group_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		helper := NewNetworkSecurityGroupHelper(t)
		nsg := helper.GetNsgProperties(t, resourceGroupName, nsgName)
		assert.Equal(t, "true", *nsg.Tags["Update"])
	})
}

// TestNsgCompliance tests security and compliance scenarios.
func TestNsgCompliance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "modules/azurerm_network_security_group/tests/fixtures/security")

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
		nsgName := terraform.Output(t, terraformOptions, "network_security_group_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		helper := NewNetworkSecurityGroupHelper(t)
		nsg := helper.GetNsgProperties(t, resourceGroupName, nsgName)

		// Example compliance check: Ensure no rules allow unrestricted access from the internet
		for _, rule := range nsg.Properties.SecurityRules {
			if *rule.Properties.Access == "Allow" && *rule.Properties.Direction == "Inbound" {
				assert.NotEqual(t, "*", *rule.Properties.SourceAddressPrefix, "Rule %s allows unrestricted access from the internet", *rule.Name)
				assert.NotEqual(t, "Internet", *rule.Properties.SourceAddressPrefix, "Rule %s allows unrestricted access from the internet", *rule.Name)
			}
		}
	})
}
