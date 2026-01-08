package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestAzuredevopsUserEntitlementFullIntegration performs a full apply on the complete fixture.
func TestAzuredevopsUserEntitlementFullIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	fixtureName := "complete"
	requireADOEnv(t, fixtureName)

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

		userID := terraform.Output(t, terraformOptions, "user_entitlement_id")
		userDescriptor := terraform.Output(t, terraformOptions, "user_entitlement_descriptor")
		userKey := terraform.Output(t, terraformOptions, "user_entitlement_key")

		assert.NotEmpty(t, userID)
		assert.NotEmpty(t, userDescriptor)
		assert.Equal(t, "fixture-complete-user", userKey)
	})
}
