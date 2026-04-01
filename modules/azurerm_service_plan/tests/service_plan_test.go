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
	"github.com/stretchr/testify/require"
)

// Test basic service_plan creation.
func TestBasicServicePlan(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		resourceID := terraform.Output(t, terraformOptions, "service_plan_id")
		resourceName := terraform.Output(t, terraformOptions, "service_plan_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		resourceKind := terraform.Output(t, terraformOptions, "service_plan_kind")
		skuName := terraform.Output(t, terraformOptions, "sku_name")
		reserved := OutputBool(t, terraformOptions, "reserved")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.NotEmpty(t, resourceKind)
		assert.Equal(t, "B1", skuName)
		assert.False(t, reserved)

		helper := NewServicePlanHelper(t)
		servicePlan := helper.GetServicePlan(t, resourceGroupName, resourceName)
		assert.NotEmpty(t, servicePlan.ID)
		assert.NotEmpty(t, servicePlan.Name)
		ValidateServicePlanTags(t, servicePlan, map[string]string{
			"Environment": "Test",
			"Example":     "Basic",
		})
	})
}

// Test complete service_plan with diagnostics and per-site scaling.
func TestCompleteServicePlan(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/complete")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		resourceID := terraform.Output(t, terraformOptions, "service_plan_id")
		resourceName := terraform.Output(t, terraformOptions, "service_plan_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		reserved := OutputBool(t, terraformOptions, "reserved")
		workerCount := OutputInt(t, terraformOptions, "worker_count")
		perSiteScalingEnabled := OutputBool(t, terraformOptions, "per_site_scaling_enabled")
		diagnosticSettingsSkippedCount := OutputInt(t, terraformOptions, "diagnostic_settings_skipped_count")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.True(t, reserved)
		assert.Equal(t, 1, workerCount)
		assert.True(t, perSiteScalingEnabled)
		assert.Equal(t, 0, diagnosticSettingsSkippedCount)

		helper := NewServicePlanHelper(t)
		servicePlan := helper.GetServicePlan(t, resourceGroupName, resourceName)
		ValidateServicePlanTags(t, servicePlan, map[string]string{
			"Environment": "Test",
			"Example":     "Complete",
		})
	})
}

// Test secure configuration baseline.
func TestSecureServicePlan(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/secure")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		resourceID := terraform.Output(t, terraformOptions, "service_plan_id")
		resourceName := terraform.Output(t, terraformOptions, "service_plan_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		reserved := OutputBool(t, terraformOptions, "reserved")
		diagnosticSettingsSkippedCount := OutputInt(t, terraformOptions, "diagnostic_settings_skipped_count")

		assert.NotEmpty(t, resourceID)
		assert.NotEmpty(t, resourceName)
		assert.NotEmpty(t, resourceGroupName)
		assert.False(t, reserved)
		assert.Equal(t, 0, diagnosticSettingsSkippedCount)

		helper := NewServicePlanHelper(t)
		servicePlan := helper.GetServicePlan(t, resourceGroupName, resourceName)
		ValidateServicePlanTags(t, servicePlan, map[string]string{
			"Environment": "Test",
			"Example":     "Secure",
		})
	})
}

// Negative test cases for validation rules.
func TestServicePlanValidationRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		fixtureFile   string
		expectedError string
	}{
		{
			name:          "InvalidZoneBalancingConfiguration",
			fixtureFile:   "negative",
			expectedError: "zone_balancing_enabled",
		},
	}

	for _, tc := range testCases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", fmt.Sprintf("tests/fixtures/%s", tc.fixtureFile))
			terraformOptions := &terraform.Options{
				TerraformDir: testFolder,
				NoColor:      true,
			}

			_, err := terraform.InitAndPlanE(t, terraformOptions)
			require.Error(t, err)
			if tc.expectedError != "" {
				assert.Contains(t, strings.ToLower(err.Error()), strings.ToLower(tc.expectedError))
			}
		})
	}
}

// Benchmark test for performance.
func BenchmarkServicePlanCreation(b *testing.B) {
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(b, testFolder)
	defer terraform.Destroy(b, terraformOptions)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])

		terraform.InitAndApply(b, terraformOptions)
		terraform.Destroy(b, terraformOptions)
	}
}

// Helper function to get terraform options.
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
		EnvVars: map[string]string{
			"TF_CLI_ARGS_apply": "-parallelism=1",
		},
		NoColor: true,
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":                                 "Timeout error - retrying",
			".*ResourceGroupNotFound.*":                   "Resource group not found - retrying",
			".*AlreadyExists.*":                           "Resource already exists - retrying",
			".*TooManyRequests.*":                         "Too many requests - retrying",
			".*Conflict.*":                                "Azure returned a conflict - retrying",
			".*another operation is in progress.*":        "Another App Service operation is in progress - retrying",
			".*The request failed due to conflict.*":      "Conflicting request on App Service Plan - retrying",
			".*Cannot modify this site because another.*": "App Service backend propagation delay - retrying",
		},
		MaxRetries:         8,
		TimeBetweenRetries: 20 * time.Second,
	}
}
