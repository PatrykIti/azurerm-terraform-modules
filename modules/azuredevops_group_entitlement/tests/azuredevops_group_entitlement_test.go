package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestBasicAzuredevopsGroupEntitlement(t *testing.T) {
	t.Parallel()
	fixtureName := "basic"
	requireADOGroupEntitlementEnv(t, fixtureName)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder, fixtureName))
	})

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions := getTerraformOptions(t, testFolder, fixtureName)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		entitlementID := terraform.Output(t, terraformOptions, "group_entitlement_id")
		entitlementDescriptor := terraform.Output(t, terraformOptions, "group_entitlement_descriptor")
		entitlementKey := terraform.Output(t, terraformOptions, "group_entitlement_key")

		assert.NotEmpty(t, entitlementID)
		assert.NotEmpty(t, entitlementDescriptor)
		assert.Equal(t, "fixture-basic-group", entitlementKey)
	})
}

func TestCompleteAzuredevopsGroupEntitlement(t *testing.T) {
	t.Parallel()
	fixtureName := "complete"
	requireADOGroupEntitlementEnv(t, fixtureName)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder, fixtureName))
	})

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions := getTerraformOptions(t, testFolder, fixtureName)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		entitlementID := terraform.Output(t, terraformOptions, "group_entitlement_id")
		entitlementDescriptor := terraform.Output(t, terraformOptions, "group_entitlement_descriptor")
		entitlementKey := terraform.Output(t, terraformOptions, "group_entitlement_key")

		assert.NotEmpty(t, entitlementID)
		assert.NotEmpty(t, entitlementDescriptor)
		assert.Equal(t, "fixture-complete-group", entitlementKey)
	})
}

func TestSecureAzuredevopsGroupEntitlement(t *testing.T) {
	t.Parallel()
	fixtureName := "secure"
	requireADOGroupEntitlementEnv(t, fixtureName)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder, fixtureName))
	})

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions := getTerraformOptions(t, testFolder, fixtureName)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		entitlementID := terraform.Output(t, terraformOptions, "group_entitlement_id")
		entitlementDescriptor := terraform.Output(t, terraformOptions, "group_entitlement_descriptor")
		entitlementKey := terraform.Output(t, terraformOptions, "group_entitlement_key")

		assert.NotEmpty(t, entitlementID)
		assert.NotEmpty(t, entitlementDescriptor)
		assert.Equal(t, "fixture-secure-group", entitlementKey)
	})
}

func TestAzuredevopsGroupEntitlementValidationRules(t *testing.T) {
	t.Parallel()
	fixtureName := "negative"
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/negative")
	terraformOptions := getTerraformOptions(t, testFolder, fixtureName)

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "group_entitlement must set either display_name or origin+origin_id")
}
