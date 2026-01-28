package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// Test basic Data Collection Rule creation
func TestBasicMonitorDataCollectionRule(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_monitor_data_collection_rule/tests/fixtures/basic")
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

		resourceID := terraform.Output(t, terraformOptions, "monitor_data_collection_rule_id")
		resourceName := terraform.Output(t, terraformOptions, "monitor_data_collection_rule_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
	})
}

// Test complete Data Collection Rule configuration
func TestCompleteMonitorDataCollectionRule(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_monitor_data_collection_rule/tests/fixtures/complete")
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

		resourceID := terraform.Output(t, terraformOptions, "monitor_data_collection_rule_id")
		resourceName := terraform.Output(t, terraformOptions, "monitor_data_collection_rule_name")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
	})
}

// Test secure Data Collection Rule configuration
func TestSecureMonitorDataCollectionRule(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_monitor_data_collection_rule/tests/fixtures/secure")
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

		resourceID := terraform.Output(t, terraformOptions, "monitor_data_collection_rule_id")
		endpointID := terraform.Output(t, terraformOptions, "data_collection_endpoint_id")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, endpointID)
	})
}

// Negative test cases for validation rules
func TestMonitorDataCollectionRuleValidationRules(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_monitor_data_collection_rule/tests/fixtures/negative")
	terraformOptions := &terraform.Options{
		TerraformDir: testFolder,
		Vars: map[string]interface{}{
			"random_suffix": "invalid",
			"location":      "northeurope",
		},
		NoColor: true,
	}

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	assert.Error(t, err)
}

// Benchmark test for performance
func BenchmarkMonitorDataCollectionRuleCreation(b *testing.B) {
	for i := 0; i < b.N; i++ {
		testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "azurerm_monitor_data_collection_rule/tests/fixtures/basic")
		terraformOptions := getTerraformOptions(b, testFolder)
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("bench%03d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])

		terraform.InitAndApply(b, terraformOptions)
		terraform.Destroy(b, terraformOptions)
	}
}

func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	timestamp := time.Now().UnixNano() % 1000
	baseID := strings.ToLower(random.UniqueId())
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
