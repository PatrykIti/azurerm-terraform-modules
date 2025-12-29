package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestAzuredevopsIdentityFullIntegration performs a full apply on the complete fixture.
func TestAzuredevopsIdentityFullIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/complete")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		if userPrincipal := os.Getenv("AZDO_TEST_USER_PRINCIPAL_NAME"); userPrincipal != "" {
			terraformOptions.Vars["user_principal_name"] = userPrincipal
		}
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		groupID := terraform.Output(t, terraformOptions, "group_id")
		groupMemberships := terraform.OutputMap(t, terraformOptions, "group_membership_ids")

		assert.NotEmpty(t, groupID)
		assert.NotEmpty(t, groupMemberships)
		assert.Contains(t, groupMemberships, "platform-membership")

		if userPrincipal := os.Getenv("AZDO_TEST_USER_PRINCIPAL_NAME"); userPrincipal != "" {
			userEntitlements := terraform.OutputMap(t, terraformOptions, "user_entitlement_ids")
			assert.Contains(t, userEntitlements, "fixture-user")
		}
	})
}
