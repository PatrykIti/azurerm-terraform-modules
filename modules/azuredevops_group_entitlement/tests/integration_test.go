package test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestAzuredevopsGroupEntitlementFullIntegration performs a full apply on the complete fixture.
func TestAzuredevopsGroupEntitlementFullIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	fixtureName := "complete"
	requireADOGroupEntitlementEnv(t, fixtureName)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
	terraformOptions := getTerraformOptions(t, testFolder, fixtureName)
	defer test_structure.RunTestStage(t, "cleanup", func() {
		if _, err := os.Stat(filepath.Join(testFolder, ".test-data", "TerraformOptions.json")); err == nil {
			terraform.Destroy(t, test_structure.LoadTerraformOptions(t, testFolder))
			return
		}
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "setup", func() {
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		entitlementID := terraform.Output(t, terraformOptions, "group_entitlement_id")
		assert.NotEmpty(t, entitlementID)
	})
}
