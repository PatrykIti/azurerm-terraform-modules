package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkKubernetesNamespaceCreation benchmarks the creation of a basic namespace setup
func BenchmarkKubernetesNamespaceCreation(b *testing.B) {
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "kubernetes_namespace/tests/fixtures/basic")
		terraformOptions := getTerraformOptions(b, testFolder)
		b.StartTimer()

		applyWithClusterFirst(b, terraformOptions)

		b.StopTimer()
		terraform.Destroy(b, terraformOptions)
	}
}

// TestKubernetesNamespaceCreationTime validates creation time is within the SLA
func TestKubernetesNamespaceCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_namespace/tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	start := time.Now()
	applyWithClusterFirst(t, terraformOptions)
	duration := time.Since(start)

	maxDuration := 25 * time.Minute
	require.LessOrEqual(t, duration, maxDuration, "Kubernetes namespace creation took %v, expected less than %v", duration, maxDuration)
}
