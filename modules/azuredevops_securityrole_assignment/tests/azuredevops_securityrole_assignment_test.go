package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic azuredevops_securityrole_assignment creation
func TestBasicAzuredevopsSecurityroleAssignment(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder, getScopeIDBasic(t), getResourceIDBasic(t), getIdentityIDBasic(t)))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder, getScopeIDBasic(t), getResourceIDBasic(t), getIdentityIDBasic(t))
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		assignmentID := terraform.Output(t, terraformOptions, "securityrole_assignment_id")

		assert.NotEmpty(t, assignmentID)
	})
}

// Test complete azuredevops_securityrole_assignment configuration
func TestCompleteAzuredevopsSecurityroleAssignment(t *testing.T) {
	t.Parallel()
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

// Test secure azuredevops_securityrole_assignment configuration
func TestSecureAzuredevopsSecurityroleAssignment(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder, getScopeIDSecure(t), getResourceIDSecure(t), getIdentityIDSecure(t)))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder, getScopeIDSecure(t), getResourceIDSecure(t), getIdentityIDSecure(t))
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		assignmentID := terraform.Output(t, terraformOptions, "securityrole_assignment_id")

		assert.NotEmpty(t, assignmentID)
	})
}

// Negative test cases for validation rules
func TestAzuredevopsSecurityroleAssignmentValidationRules(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/negative")
	terraformOptions := &terraform.Options{
		TerraformDir: testFolder,
		NoColor:      true,
	}

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "identity_id must be a non-empty string")
}
