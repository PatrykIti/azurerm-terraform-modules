package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkPrivateEndpointCreationSimple benchmarks basic private endpoint creation.
func BenchmarkPrivateEndpointCreationSimple(b *testing.B) {
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
		terraformOptions := getTerraformOptions(b, testFolder)
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("bench%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])
		b.StartTimer()

		start := time.Now()
		terraform.InitAndApply(b, terraformOptions)
		creationTime := time.Since(start)

		b.StopTimer()
		terraform.Destroy(b, terraformOptions)
		b.StartTimer()

		b.ReportMetric(float64(creationTime.Milliseconds()), "creation_ms")
	}
}

// BenchmarkPrivateEndpointCreationWithFeatures benchmarks a private endpoint with DNS group and IP config.
func BenchmarkPrivateEndpointCreationWithFeatures(b *testing.B) {
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/complete")
		terraformOptions := getTerraformOptions(b, testFolder)
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("benchc%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])
		b.StartTimer()

		start := time.Now()
		terraform.InitAndApply(b, terraformOptions)
		creationTime := time.Since(start)

		b.StopTimer()
		terraform.Destroy(b, terraformOptions)
		b.StartTimer()

		b.ReportMetric(float64(creationTime.Milliseconds()), "creation_ms")
	}
}

// BenchmarkPrivateEndpointParallelCreation benchmarks parallel creation of private endpoints.
func BenchmarkPrivateEndpointParallelCreation(b *testing.B) {
	parallelCounts := []int{1, 2, 5}

	for _, parallel := range parallelCounts {
		b.Run(fmt.Sprintf("Parallel_%d", parallel), func(b *testing.B) {
			b.SetParallelism(parallel)
			b.RunParallel(func(pb *testing.PB) {
				i := 0
				for pb.Next() {
					testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
					terraformOptions := getTerraformOptions(b, testFolder)
					terraformOptions.Vars["random_suffix"] = fmt.Sprintf("par%d%d%s", parallel, i, terraformOptions.Vars["random_suffix"].(string)[:5])

					start := time.Now()
					terraform.InitAndApply(b, terraformOptions)
					creationTime := time.Since(start)

					terraform.Destroy(b, terraformOptions)

					b.ReportMetric(float64(creationTime.Milliseconds()), "creation_ms")
					i++
				}
			})
		})
	}
}

// TestPrivateEndpointCreationTime validates creation time is within acceptable limits.
func TestPrivateEndpointCreationTime(t *testing.T) {
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

	maxDuration := 10 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"Private Endpoint creation took %v, expected less than %v", duration, maxDuration)
}

// TestPrivateEndpointScaling tests creating multiple private endpoints.
func TestPrivateEndpointScaling(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping scaling test in short mode")
	}

	instanceCount := 2
	creationTimes := make([]time.Duration, instanceCount)

	for i := 0; i < instanceCount; i++ {
		testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
		terraformOptions := getTerraformOptions(t, testFolder)
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("scale%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])

		start := time.Now()
		terraform.InitAndApply(t, terraformOptions)
		creationTimes[i] = time.Since(start)

		terraform.Destroy(t, terraformOptions)
	}

	var totalTime time.Duration
	for _, duration := range creationTimes {
		totalTime += duration
	}
	avgTime := totalTime / time.Duration(instanceCount)

	require.LessOrEqual(t, avgTime, 10*time.Minute,
		"Average creation time %v exceeds maximum of 10 minutes", avgTime)
}

// TestPrivateEndpointUpdatePerformance tests update performance (tags).
func TestPrivateEndpointUpdatePerformance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	terraformOptions.Vars["tags"] = map[string]interface{}{
		"Environment": "Test",
		"Updated":     "true",
	}

	start := time.Now()
	terraform.Apply(t, terraformOptions)
	updateTime := time.Since(start)

	require.LessOrEqual(t, updateTime, 5*time.Minute,
		"Update time %v exceeds maximum of 5 minutes", updateTime)
}
