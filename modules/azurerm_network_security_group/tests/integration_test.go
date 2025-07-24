package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestNetworkSecurityGroupLifecycle tests the resource lifecycle (update, idempotency).
func TestNetworkSecurityGroupLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
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

	test_structure.RunTestStage(t, "validate_initial", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		nsgName := terraform.Output(t, terraformOptions, "name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		helper := NewNetworkSecurityGroupHelper(t)
		nsg := helper.GetNsgProperties(t, resourceGroupName, nsgName)
		assert.NotContains(t, nsg.Tags, "Update", "Initial tags should not contain 'Update'.")
	})

	test_structure.RunTestStage(t, "update", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		// Note: getTerraformOptions creates a new random_suffix each time.
		// For a true update test, we should load, modify, and save.
		// But for a simple tag update, this is sufficient to test the apply stage.
		terraformOptions.Vars["tags"] = map[string]interface{}{
			"Environment": "Test",
			"Scenario":    "Simple",
			"Update":      "true",
		}
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.Apply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate_update", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		nsgName := terraform.Output(t, terraformOptions, "name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		helper := NewNetworkSecurityGroupHelper(t)
		nsg := helper.GetNsgProperties(t, resourceGroupName, nsgName)
		assert.Equal(t, "true", *nsg.Tags["Update"], "Tag 'Update' should be 'true' after update.")
	})
}

// TestSecureNetworkSecurityGroup tests security and compliance scenarios using the 'security' fixture.
func TestSecureNetworkSecurityGroup(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_network_security_group/tests/fixtures/security")

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

		// The fixture defines 2 custom rules.
		helper.ValidateNsgSecurityRules(t, nsg, 2)

		// Example compliance check: Ensure the high-priority deny rule is present.
		var denyRuleFound bool
		for _, rule := range nsg.Properties.SecurityRules {
			if *rule.Name == "deny_all_inbound" {
				denyRuleFound = true
				assert.Equal(t, int32(4000), *rule.Properties.Priority, "Deny rule should have priority 4000.")
				assert.Equal(t, "Deny", string(*rule.Properties.Access), "Deny rule should have access 'Deny'.")
				break
			}
		}
		assert.True(t, denyRuleFound, "High-priority deny rule was not found.")
	})
}