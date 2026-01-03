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

// Test basic Kubernetes Secrets configuration (manual strategy)
func TestBasicKubernetesSecrets(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_secrets/tests/fixtures/basic")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		applyWithClusterFirst(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		strategy := terraform.Output(t, terraformOptions, "strategy")
		secretName := terraform.Output(t, terraformOptions, "kubernetes_secret_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		assert.Equal(t, "manual", strategy)
		assert.NotEmpty(t, secretName)
		assert.NotEmpty(t, resourceGroupName)
	})
}

// Test complete Kubernetes Secrets configuration (CSI strategy)
func TestCompleteKubernetesSecrets(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_secrets/tests/fixtures/complete")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		applyWithClusterFirst(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		strategy := terraform.Output(t, terraformOptions, "strategy")
		secretProviderClassName := terraform.Output(t, terraformOptions, "secret_provider_class_name")
		secretName := terraform.Output(t, terraformOptions, "kubernetes_secret_name")

		assert.Equal(t, "csi", strategy)
		assert.NotEmpty(t, secretProviderClassName)
		assert.NotEmpty(t, secretName)
	})
}

// Test secure Kubernetes Secrets configuration (ESO strategy)
func TestSecureKubernetesSecrets(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_secrets/tests/fixtures/secure")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		destroyWithoutRefresh(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		applyWithClusterFirstAndSetup(t, terraformOptions, func() {
			ensureESOCRDs(t, terraformOptions)
		})
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		strategy := terraform.Output(t, terraformOptions, "strategy")
		secretStoreName := terraform.Output(t, terraformOptions, "secret_store_name")
		externalSecretNames := terraform.OutputList(t, terraformOptions, "external_secret_names")

		assert.Equal(t, "eso", strategy)
		assert.NotEmpty(t, secretStoreName)
		assert.Greater(t, len(externalSecretNames), 0)
	})
}

// Test additional fixture (network naming scenario)
func TestNetworkKubernetesSecrets(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_secrets/tests/fixtures/network")
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

		strategy := terraform.Output(t, terraformOptions, "strategy")
		secretName := terraform.Output(t, terraformOptions, "kubernetes_secret_name")

		assert.Equal(t, "manual", strategy)
		assert.NotEmpty(t, secretName)
	})
}

// Negative test cases for validation rules
func TestKubernetesSecretsValidationRules(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_secrets/tests/fixtures/negative")

	terraformOptions := &terraform.Options{
		TerraformDir: testFolder,
		NoColor:      true,
	}

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "name must be a valid DNS-1123 label")
}

// Helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	// Generate a unique ID for resources
	timestamp := time.Now().UnixNano() % 1000 // Last 3 digits for more variation
	baseID := strings.ToLower(random.UniqueId())
	uniqueID := fmt.Sprintf("%s%03d", baseID[:5], timestamp)

	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"random_suffix": uniqueID,
			"location":      "northeurope",
		},
		NoColor: true,
		// Retry configuration
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

func applyWithClusterFirst(t testing.TB, terraformOptions *terraform.Options) {
	applyWithClusterFirstAndSetup(t, terraformOptions, nil)
}

func applyWithClusterFirstAndSetup(t testing.TB, terraformOptions *terraform.Options, setup func()) {
	terraform.Init(t, terraformOptions)

	targetOptions := *terraformOptions
	targetOptions.Targets = []string{"module.kubernetes_cluster"}

	terraform.Apply(t, &targetOptions)
	if setup != nil {
		setup()
	}
	terraform.Apply(t, terraformOptions)
}

func destroyWithoutRefresh(t testing.TB, terraformOptions *terraform.Options) {
	// Avoid refresh to keep kube_config values for the Kubernetes provider during cleanup.
	args := terraform.FormatArgs(terraformOptions, "destroy", "-auto-approve", "-input=false", "-refresh=false")
	terraform.RunTerraformCommand(t, terraformOptions, args...)
}
