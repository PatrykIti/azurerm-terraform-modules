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
)

// Test basic azuredevops_elastic_pool creation
func TestBasicAzuredevopsElasticPool(t *testing.T) {
	t.Parallel()
	requireADOElasticEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
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

		elasticPoolID := terraform.Output(t, terraformOptions, "elastic_pool_id")

		assert.NotEmpty(t, elasticPoolID)
	})
}

// Test complete azuredevops_elastic_pool configuration
func TestCompleteAzuredevopsElasticPool(t *testing.T) {
	t.Parallel()
	requireADOElasticEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
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

		elasticPoolID := terraform.Output(t, terraformOptions, "elastic_pool_id")

		assert.NotEmpty(t, elasticPoolID)
	})
}

// Test secure azuredevops_elastic_pool configuration
func TestSecureAzuredevopsElasticPool(t *testing.T) {
	t.Parallel()
	requireADOElasticEnv(t)

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
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

		elasticPoolID := terraform.Output(t, terraformOptions, "elastic_pool_id")

		assert.NotEmpty(t, elasticPoolID)
	})
}

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	t.Helper()

	uniqueID := random.UniqueId()

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"elastic_pool_name_prefix": fmt.Sprintf("ado-elastic-pool-%s", uniqueID),
			"service_endpoint_id":      os.Getenv("AZDO_TEST_SERVICE_ENDPOINT_ID"),
			"service_endpoint_scope":   os.Getenv("AZDO_TEST_SERVICE_ENDPOINT_SCOPE"),
			"azure_resource_id":        os.Getenv("AZDO_TEST_AZURE_RESOURCE_ID"),
		},
		NoColor: true,
		Upgrade: true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":         "Timeout error - retrying",
			".*TooManyRequests.*": "Too many requests - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
