package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkKubernetesSecretsCreation benchmarks the creation of a basic secrets setup
func BenchmarkKubernetesSecretsCreation(b *testing.B) {
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "azurerm_kubernetes_secrets/tests/fixtures/basic")
		terraformOptions := getTerraformOptions(b, testFolder)
		b.StartTimer()

		terraform.InitAndApply(b, terraformOptions)

		b.StopTimer()
		terraform.Destroy(b, terraformOptions)
	}
}

// TestKubernetesSecretsCreationTime validates creation time is within the SLA
func TestKubernetesSecretsCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_secrets/tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	// Creation includes AKS + Key Vault + K8s resources.
	maxDuration := 25 * time.Minute
	require.LessOrEqual(t, duration, maxDuration, "Kubernetes secrets creation took %v, expected less than %v", duration, maxDuration)
}
