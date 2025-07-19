package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestRouteTableBasic(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "modules/azurerm_route_table/tests/fixtures/basic")

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
		id := terraform.Output(t, terraformOptions, "route_table_id")
		name := terraform.Output(t, terraformOptions, "route_table_name")

		assert.NotEmpty(t, id)
		assert.NotEmpty(t, name)
	})
}

func TestRouteTableComplete(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "modules/azurerm_route_table/tests/fixtures/complete")

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
		id := terraform.OutputMap(t, terraformOptions, "complete_route_table")["id"]
		name := terraform.OutputMap(t, terraformOptions, "complete_route_table")["name"]

		assert.NotEmpty(t, id)
		assert.NotEmpty(t, name)
	})
}

func TestRouteTableSecure(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "modules/azurerm_route_table/tests/fixtures/secure")

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
		id := terraform.Output(t, terraformOptions, "route_table_id")
		name := terraform.Output(t, terraformOptions, "route_table_name")

		assert.NotEmpty(t, id)
		assert.NotEmpty(t, name)
	})
}

func TestRouteTableValidationRules(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "modules/azurerm_route_table/tests/fixtures/negative")

	terraformOptions := &terraform.Options{
		TerraformDir: testFolder,
		Vars: map[string]interface{}{
			"random_suffix": "neg",
		},
	}

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "Route Table name must be 1-80 characters long")
}
