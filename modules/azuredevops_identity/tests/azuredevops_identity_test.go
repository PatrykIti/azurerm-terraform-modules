package test

import (
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic azuredevops_identity creation
func TestBasicAzuredevopsIdentity(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_identity/tests/fixtures/basic")
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
		groupDescriptor := terraform.Output(t, terraformOptions, "group_descriptor")

		assert.NotEmpty(t, groupID)
		assert.NotEmpty(t, groupDescriptor)
	})
}

// Test complete azuredevops_identity with memberships
func TestCompleteAzuredevopsIdentity(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_identity/tests/fixtures/complete")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
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

// Test secure azuredevops_identity configuration
func TestSecureAzuredevopsIdentity(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_identity/tests/fixtures/secure")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		groupID := terraform.Output(t, terraformOptions, "group_id")
		groupMemberships := terraform.OutputMap(t, terraformOptions, "group_membership_ids")

		assert.NotEmpty(t, groupID)
		assert.NotEmpty(t, groupMemberships)
		assert.Contains(t, groupMemberships, "security-membership")
	})
}

// Validate group membership selector rules
func TestAzuredevopsIdentityValidationRules(t *testing.T) {
	t.Parallel()
	requireADOEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azuredevops_identity/tests/fixtures/negative")
	terraformOptions := getTerraformOptions(t, testFolder)

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "group_memberships.group_descriptor is required")
}

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	t.Helper()

	uniqueID := random.UniqueId()

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"group_name_prefix": fmt.Sprintf("ado-identity-%s", uniqueID),
		},
		NoColor: true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":         "Timeout error - retrying",
			".*TooManyRequests.*": "Too many requests - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
