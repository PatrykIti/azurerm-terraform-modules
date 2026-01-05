package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkKubernetesClusterCreation benchmarks the creation of a basic AKS cluster
func BenchmarkKubernetesClusterCreation(b *testing.B) {
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "azurerm_kubernetes_cluster/tests/fixtures/basic")
		terraformOptions := getTerraformOptions(b, testFolder)
		b.StartTimer()

		terraform.InitAndApply(b, terraformOptions)

		b.StopTimer()
		terraform.Destroy(b, terraformOptions)
	}
}

// TestKubernetesClusterCreationTime validates that the cluster creation time is within the SLA
func TestKubernetesClusterCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_cluster/tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	// AKS creation can be slow, so we set a generous SLA of 20 minutes.
	maxDuration := 20 * time.Minute
	require.LessOrEqual(t, duration, maxDuration, "AKS cluster creation took %v, which is longer than the SLA of %v", duration, maxDuration)
}
