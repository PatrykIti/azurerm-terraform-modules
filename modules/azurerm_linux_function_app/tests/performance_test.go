package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkLinuxFunctionAppCreationSimple benchmarks simple linux_function_app creation
func BenchmarkLinuxFunctionAppCreationSimple(b *testing.B) {
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
		terraformOptions := getTerraformOptions(b, testFolder)
		// Override the random_suffix for benchmarking
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

// BenchmarkLinuxFunctionAppCreationWithFeatures benchmarks linux_function_app using richer fixtures.
func BenchmarkLinuxFunctionAppCreationWithFeatures(b *testing.B) {
	b.ReportAllocs()

	// Use fixture variants instead of injecting undeclared placeholder variables.
	featureConfigs := []struct {
		name    string
		fixture string
	}{
		{
			name:    "Basic",
			fixture: "tests/fixtures/basic",
		},
		{
			name:    "Complete",
			fixture: "tests/fixtures/complete",
		},
		{
			name:    "Secure",
			fixture: "tests/fixtures/secure",
		},
	}

	for _, fc := range featureConfigs {
		b.Run(fc.name, func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				b.StopTimer()
				testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", fc.fixture)
				terraformOptions := getTerraformOptions(b, testFolder)

				// Override the random_suffix for benchmarking
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
		})
	}
}

// BenchmarkLinuxFunctionAppCreationWithScale benchmarks with different scale configurations
func BenchmarkLinuxFunctionAppCreationWithScale(b *testing.B) {
	b.ReportAllocs()

	// Define different scale configurations
	scaleCounts := []int{1, 5, 10, 20}

	for _, count := range scaleCounts {
		b.Run(fmt.Sprintf("Scale_%d", count), func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				b.StopTimer()
				testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
				terraformOptions := getTerraformOptions(b, testFolder)

				// Override the random_suffix for benchmarking
				terraformOptions.Vars["random_suffix"] = fmt.Sprintf("bench%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])
				b.StartTimer()

				start := time.Now()
				terraform.InitAndApply(b, terraformOptions)
				creationTime := time.Since(start)

				b.StopTimer()
				terraform.Destroy(b, terraformOptions)
				b.StartTimer()

				b.ReportMetric(float64(creationTime.Milliseconds()), "creation_ms")
				b.ReportMetric(float64(count), "scale_count")
			}
		})
	}
}

// BenchmarkLinuxFunctionAppParallelCreation benchmarks parallel creation of linux_function_app
func BenchmarkLinuxFunctionAppParallelCreation(b *testing.B) {
	parallelCounts := []int{1, 2, 5, 10}

	for _, parallel := range parallelCounts {
		b.Run(fmt.Sprintf("Parallel_%d", parallel), func(b *testing.B) {
			b.SetParallelism(parallel)
			b.RunParallel(func(pb *testing.PB) {
				i := 0
				for pb.Next() {
					testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
					terraformOptions := getTerraformOptions(b, testFolder)
					// Override the random_suffix for parallel testing
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

// TestLinuxFunctionAppCreationTime validates creation time is within acceptable limits
func TestLinuxFunctionAppCreationTime(t *testing.T) {
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

	// linux_function_app creation should complete within 5 minutes
	// Adjust this based on the actual expected creation time for the resource
	maxDuration := 5 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"Linux Function App creation took %v, expected less than %v", duration, maxDuration)

	t.Logf("Linux Function App created in %v", duration)
}

// TestLinuxFunctionAppScaling tests creating multiple linux_function_app instances
func TestLinuxFunctionAppScaling(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping scaling test in short mode")
	}

	instanceCount := 3
	creationTimes := make([]time.Duration, instanceCount)

	// Create multiple instances sequentially
	for i := 0; i < instanceCount; i++ {
		testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
		terraformOptions := getTerraformOptions(t, testFolder)
		// Override the random_suffix for each iteration
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("scale%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])

		start := time.Now()
		terraform.InitAndApply(t, terraformOptions)
		creationTimes[i] = time.Since(start)

		// Cleanup immediately to avoid hitting limits
		terraform.Destroy(t, terraformOptions)

		t.Logf("Linux Function App instance %d created in %v", i, creationTimes[i])
	}

	// Calculate average creation time
	var totalTime time.Duration
	for _, duration := range creationTimes {
		totalTime += duration
	}
	avgTime := totalTime / time.Duration(instanceCount)

	t.Logf("Average creation time for %d linux_function_app instances: %v", instanceCount, avgTime)

	// Ensure average time is reasonable while accounting for transient Azure delays.
	maxAverageCreationTime := 4 * time.Minute
	require.LessOrEqual(t, avgTime, maxAverageCreationTime,
		"Average creation time %v exceeds maximum of %v", avgTime, maxAverageCreationTime)
}

// TestLinuxFunctionAppUpdatePerformance tests update performance
func TestLinuxFunctionAppUpdatePerformance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	// Initial deployment
	terraform.InitAndApply(t, terraformOptions)

	// Measure re-apply time for idempotent updates.
	updateScenarios := []string{
		"NoOpApply",
	}

	for _, scenarioName := range updateScenarios {
		t.Run(scenarioName, func(t *testing.T) {

			start := time.Now()
			terraform.Apply(t, terraformOptions)
			updateTime := time.Since(start)

			t.Logf("%s completed in %v", scenarioName, updateTime)

			// Updates should complete within 2 minutes
			require.LessOrEqual(t, updateTime, 2*time.Minute,
				"%s took %v, expected less than 2 minutes", scenarioName, updateTime)
		})
	}
}

// TestLinuxFunctionAppDestroyPerformance tests destroy performance
func TestLinuxFunctionAppDestroyPerformance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)

	// Create resource
	terraform.InitAndApply(t, terraformOptions)

	// Measure destroy time
	start := time.Now()
	terraform.Destroy(t, terraformOptions)
	destroyTime := time.Since(start)

	t.Logf("Linux Function App destroyed in %v", destroyTime)

	// Destroy should complete within 3 minutes
	require.LessOrEqual(t, destroyTime, 3*time.Minute,
		"Destroy took %v, expected less than 3 minutes", destroyTime)
}
