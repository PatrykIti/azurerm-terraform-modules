package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic user_assigned_identity creation
func TestBasicUserAssignedIdentity(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/basic")
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

		resourceID := terraform.Output(t, terraformOptions, "user_assigned_identity_id")
		resourceName := terraform.Output(t, terraformOptions, "user_assigned_identity_name")
		clientID := terraform.Output(t, terraformOptions, "user_assigned_identity_client_id")
		principalID := terraform.Output(t, terraformOptions, "user_assigned_identity_principal_id")
		tenantID := terraform.Output(t, terraformOptions, "user_assigned_identity_tenant_id")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, clientID)
		assert.NotEmpty(t, principalID)
		assert.NotEmpty(t, tenantID)
		assert.NotEmpty(t, resourceGroupName)
	})
}

// Test complete user_assigned_identity with federated identity credentials
func TestCompleteUserAssignedIdentity(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/complete")
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

		resourceID := terraform.Output(t, terraformOptions, "user_assigned_identity_id")
		resourceName := terraform.Output(t, terraformOptions, "user_assigned_identity_name")
		federatedCredentials := terraform.OutputMapOfObjects(t, terraformOptions, "federated_identity_credentials")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.GreaterOrEqual(t, len(federatedCredentials), 2)
	})
}

// Test security configuration with least-privilege RBAC
func TestSecureUserAssignedIdentity(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/secure")
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

		resourceID := terraform.Output(t, terraformOptions, "user_assigned_identity_id")
		roleAssignmentID := terraform.Output(t, terraformOptions, "role_assignment_id")
		federatedCredentials := terraform.OutputMapOfObjects(t, terraformOptions, "federated_identity_credentials")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, roleAssignmentID)
		assert.GreaterOrEqual(t, len(federatedCredentials), 1)
	})
}

// Test dedicated federated identity credentials fixture
func TestFederatedIdentityCredentials(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/federated-identity-credentials")
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

		resourceID := terraform.Output(t, terraformOptions, "user_assigned_identity_id")
		federatedCredentials := terraform.OutputMapOfObjects(t, terraformOptions, "federated_identity_credentials")

		assert.NotEmpty(t, resourceID)
		assert.Equal(t, 2, len(federatedCredentials))
	})
}

// Negative test cases for validation rules
func TestUserAssignedIdentityValidationRules(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/negative")
	terraformOptions := &terraform.Options{
		TerraformDir: testFolder,
		NoColor:      true,
	}

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
}

// Benchmark test for performance
func BenchmarkUserAssignedIdentityCreation(b *testing.B) {
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(b, ".", "fixtures/basic")
	terraformOptions := getTerraformOptions(b, testFolder)

	defer terraform.Destroy(b, terraformOptions)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])

		terraform.InitAndApply(b, terraformOptions)
		terraform.Destroy(b, terraformOptions)
	}
}

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	timestamp := time.Now().UnixNano() % 1000
	baseID := random.UniqueId()
	uniqueID := fmt.Sprintf("%s%03d", baseID[:5], timestamp)

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"random_suffix": uniqueID,
			"location":      "northeurope",
		},
		NoColor: true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":               "Timeout error - retrying",
			".*ResourceGroupNotFound.*": "Resource group not found - retrying",
			".*AlreadyExists.*":         "Resource already exists - retrying",
			".*TooManyRequests.*":       "Too many requests - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
