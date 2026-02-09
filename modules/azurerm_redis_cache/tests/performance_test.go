package test

import (
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkRedisCacheCreationSimple benchmarks simple Redis Cache creation.
func BenchmarkRedisCacheCreationSimple(b *testing.B) {
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

// TestRedisCacheCreationTime validates creation time is within an acceptable limit.
func TestRedisCacheCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	if os.Getenv("RUN_PERFORMANCE_TESTS") != "1" {
		t.Skip("Skipping performance test by default; set RUN_PERFORMANCE_TESTS=1 to enable.")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	maxDuration := 45 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"Redis Cache creation took %v, expected less than %v", duration, maxDuration)
}
