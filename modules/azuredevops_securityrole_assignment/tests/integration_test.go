package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestAzuredevopsSecurityroleAssignmentFullIntegration performs a full apply on the complete fixture.
func TestAzuredevopsSecurityroleAssignmentFullIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder, getScopeIDComplete(t), getResourceIDComplete(t), getIdentityIDComplete(t)))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder, getScopeIDComplete(t), getResourceIDComplete(t), getIdentityIDComplete(t))
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		assignmentID := terraform.Output(t, terraformOptions, "securityrole_assignment_id")

		assert.NotEmpty(t, assignmentID)
	})
}
