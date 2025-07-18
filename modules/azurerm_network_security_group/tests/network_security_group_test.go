package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestNsgSimple tests the simple NSG fixture.
func TestNsgSimple(t *testing.T) {
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

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		nsqName := terraform.Output(t, terraformOptions, "network_security_group_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		helper := NewNetworkSecurityGroupHelper(t)
		nsg := helper.GetNsgProperties(t, resourceGroupName, nsqName)

		assert.Equal(t, nsqName, *nsg.Name)
		// Default rules + custom rules. Adjust if defaults change.
		helper.ValidateNsgSecurityRules(t, nsg, 0)
	})
}

// TestNsgComplete tests the complete NSG fixture.
func TestNsgComplete(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "modules/azurerm_network_security_group/tests/fixtures/complete")

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

		assert.Equal(t, nsgName, *nsg.Name)
		// Add more specific assertions for the 'complete' fixture
	})
}

// TestNsgValidationRules tests the input validation rules.
func TestNsgValidationRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		fixtureFolder string
		expectedError string
	}{
		{
			name:          "InvalidName",
			fixtureFolder: "negative/invalid_name_chars",
			expectedError: "does not match the regular expression",
		},
	}

	for _, tc := range testCases {
		tc := tc // Capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "modules/azurerm_network_security_group/tests/fixtures/"+tc.fixtureFolder)

			terraformOptions := &terraform.Options{
				TerraformDir: testFolder,
			}

			_, err := terraform.InitAndPlanE(t, terraformOptions)
			require.Error(t, err)
			assert.Contains(t, err.Error(), tc.expectedError)
		})
	}
}
