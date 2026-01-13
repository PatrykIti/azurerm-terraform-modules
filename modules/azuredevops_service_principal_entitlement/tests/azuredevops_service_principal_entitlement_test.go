package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic azuredevops_service_principal_entitlement creation
func TestBasicAzuredevopsServicePrincipalEntitlement(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)
	originID := requireServicePrincipalOriginID(t, "AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_BASIC")

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder, originID))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder, originID)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		entitlementID := terraform.Output(t, terraformOptions, "service_principal_entitlement_id")
		descriptor := terraform.Output(t, terraformOptions, "service_principal_entitlement_descriptor")

		assert.NotEmpty(t, entitlementID)
		assert.NotEmpty(t, descriptor)
	})
}

// Test complete azuredevops_service_principal_entitlement configuration
func TestCompleteAzuredevopsServicePrincipalEntitlement(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)
	originID := requireServicePrincipalOriginID(t, "AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_COMPLETE")

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder, originID))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder, originID)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		entitlementID := terraform.Output(t, terraformOptions, "service_principal_entitlement_id")
		descriptor := terraform.Output(t, terraformOptions, "service_principal_entitlement_descriptor")

		assert.NotEmpty(t, entitlementID)
		assert.NotEmpty(t, descriptor)
	})
}

// Test secure azuredevops_service_principal_entitlement configuration
func TestSecureAzuredevopsServicePrincipalEntitlement(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)
	originID := requireServicePrincipalOriginID(t, "AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_SECURE")

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder, originID))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder, originID)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		entitlementID := terraform.Output(t, terraformOptions, "service_principal_entitlement_id")
		descriptor := terraform.Output(t, terraformOptions, "service_principal_entitlement_descriptor")

		assert.NotEmpty(t, entitlementID)
		assert.NotEmpty(t, descriptor)
	})
}

// Validate service principal entitlement rules
func TestAzuredevopsServicePrincipalEntitlementValidationRules(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/negative")
	terraformOptions := &terraform.Options{
		TerraformDir: testFolder,
		NoColor:      true,
	}

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "origin_id must be a non-empty string")
}
