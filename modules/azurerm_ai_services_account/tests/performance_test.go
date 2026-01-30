package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkAiServicesAccountCreationSimple benchmarks simple AI Services Account creation.
func BenchmarkAiServicesAccountCreationSimple(b *testing.B) {
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
		terraformOptions := getTerraformOptions(b, testFolder)
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("bench%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])
		b.StartTimer()

		terraform.InitAndApply(b, terraformOptions)

		b.StopTimer()
		terraform.Destroy(b, terraformOptions)
		b.StartTimer()
	}
}

// TestAiServicesAccountCreationTime validates creation time is within an acceptable limit.
func TestAiServicesAccountCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	maxDuration := 30 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"AI Services Account creation took %v, expected less than %v", duration, maxDuration)
}
