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

func TestBasicKubernetesClusterRoleBinding(t *testing.T) {
	t.Parallel()
	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_cluster_role_binding/tests/fixtures/basic")
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
		assert.Equal(t, "namespace-reader-user", terraform.Output(t, terraformOptions, "cluster_role_binding_name"))
	})
}

func TestCompleteKubernetesClusterRoleBinding(t *testing.T) {
	t.Parallel()
	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_cluster_role_binding/tests/fixtures/complete")
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
		assert.Equal(t, "2", terraform.Output(t, terraformOptions, "subject_count"))
	})
}

func TestSecureKubernetesClusterRoleBinding(t *testing.T) {
	t.Parallel()
	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_cluster_role_binding/tests/fixtures/secure")
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
		assert.Equal(t, "1", terraform.Output(t, terraformOptions, "subject_count"))
	})
}

func TestKubernetesClusterRoleBindingValidationRules(t *testing.T) {
	t.Parallel()
	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_cluster_role_binding/tests/fixtures/negative")
	terraformOptions := &terraform.Options{TerraformDir: testFolder, NoColor: true}
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "subjects")
}

func BenchmarkKubernetesClusterRoleBindingCreation(b *testing.B) {
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}
	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "kubernetes_cluster_role_binding/tests/fixtures/basic")
		terraformOptions := getTerraformOptions(b, testFolder)
		b.StartTimer()
		applyWithClusterFirst(b, terraformOptions)
		b.StopTimer()
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

func applyWithClusterFirst(t testing.TB, terraformOptions *terraform.Options) {
	terraform.Init(t, terraformOptions)
	targetOptions := *terraformOptions
	targetOptions.Targets = []string{"module.kubernetes_cluster"}
	terraform.Apply(t, &targetOptions)
	terraform.Apply(t, terraformOptions)
}
