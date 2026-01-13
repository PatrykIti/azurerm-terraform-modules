package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestAzuredevopsServicePrincipalEntitlementFullIntegration performs a full apply on the complete fixture.
func TestAzuredevopsServicePrincipalEntitlementFullIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

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
