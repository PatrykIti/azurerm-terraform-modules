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

// Test basic Kubernetes Namespace configuration
func TestBasicKubernetesNamespace(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_namespace/tests/fixtures/basic")
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

		namespaceName := terraform.Output(t, terraformOptions, "namespace_name")
		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

		assert.Equal(t, "app", namespaceName)
		assert.NotEmpty(t, resourceGroupName)
	})
}

// Test complete Kubernetes Namespace configuration
func TestCompleteKubernetesNamespace(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_namespace/tests/fixtures/complete")
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

		namespaceName := terraform.Output(t, terraformOptions, "namespace_name")
		namespaceLabels := terraform.OutputMap(t, terraformOptions, "namespace_labels")

		assert.Equal(t, "intent-resolver", namespaceName)
		assert.Equal(t, "terraform", namespaceLabels["app.kubernetes.io/managed-by"])
	})
}

// Test secure Kubernetes Namespace configuration
func TestSecureKubernetesNamespace(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_namespace/tests/fixtures/secure")
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

		namespaceAnnotations := terraform.OutputMap(t, terraformOptions, "namespace_annotations")

		assert.Equal(t, "restricted", namespaceAnnotations["pod-security.kubernetes.io/enforce"])
	})
}

// Negative test cases for validation rules
func TestKubernetesNamespaceValidationRules(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_namespace/tests/fixtures/negative")

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

func applyWithClusterFirst(t testing.TB, terraformOptions *terraform.Options) {
	terraform.Init(t, terraformOptions)

	targetOptions := *terraformOptions
	targetOptions.Targets = []string{"module.kubernetes_cluster"}

	terraform.Apply(t, &targetOptions)
	terraform.Apply(t, terraformOptions)
}
