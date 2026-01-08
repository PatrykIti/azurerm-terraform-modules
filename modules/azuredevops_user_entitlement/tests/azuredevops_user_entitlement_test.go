package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic user entitlement creation
func TestBasicAzuredevopsUserEntitlement(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
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
		assert.Equal(t, "fixture-basic-user", userKey)
	})
}

// Test complete user entitlement configuration
func TestCompleteAzuredevopsUserEntitlement(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
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

// Test secure user entitlement configuration
func TestSecureAzuredevopsUserEntitlement(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
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
		assert.Equal(t, "fixture-secure-user", userKey)
	})
}

// Validate selector rules
func TestAzuredevopsUserEntitlementValidationRules(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/negative")
	terraformOptions := getTerraformOptions(t, testFolder)

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "user_entitlement must set either principal_name or origin+origin_id")
}
