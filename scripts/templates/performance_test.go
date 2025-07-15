package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkMODULE_DISPLAY_NAME_PLACEHOLDERCreationSimple benchmarks simple MODULE_TYPE_PLACEHOLDER creation
func BenchmarkMODULE_DISPLAY_NAME_PLACEHOLDERCreationSimple(b *testing.B) {
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "MODULE_NAME_PLACEHOLDER/tests/fixtures/simple")
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

// BenchmarkMODULE_DISPLAY_NAME_PLACEHOLDERCreationWithFeatures benchmarks MODULE_TYPE_PLACEHOLDER with various features
func BenchmarkMODULE_DISPLAY_NAME_PLACEHOLDERCreationWithFeatures(b *testing.B) {
	b.ReportAllocs()

	// Define different feature configurations to benchmark
	featureConfigs := []struct {
		name   string
		config map[string]interface{}
	}{
		{
			name:   "Basic",
			config: map[string]interface{}{},
		},
		{
			name: "WithSecurity",
			config: map[string]interface{}{
				"enable_advanced_security": true,
			},
		},
		{
			name: "WithMonitoring",
			config: map[string]interface{}{
				"enable_monitoring": true,
			},
		},
		{
			name: "Complete",
			config: map[string]interface{}{
				"enable_advanced_security": true,
				"enable_monitoring":        true,
				"enable_backup":            true,
			},
		},
	}

	for _, fc := range featureConfigs {
		b.Run(fc.name, func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				b.StopTimer()
				testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "MODULE_NAME_PLACEHOLDER/tests/fixtures/simple")
				terraformOptions := getTerraformOptions(b, testFolder)

				// Apply feature configuration
				for k, v := range fc.config {
					terraformOptions.Vars[k] = v
				}
				
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

// BenchmarkMODULE_DISPLAY_NAME_PLACEHOLDERCreationWithScale benchmarks with different scale configurations
func BenchmarkMODULE_DISPLAY_NAME_PLACEHOLDERCreationWithScale(b *testing.B) {
	b.ReportAllocs()

	// Define different scale configurations
	scaleCounts := []int{1, 5, 10, 20}

	for _, count := range scaleCounts {
		b.Run(fmt.Sprintf("Scale_%d", count), func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				b.StopTimer()
				testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "MODULE_NAME_PLACEHOLDER/tests/fixtures/simple")
				terraformOptions := getTerraformOptions(b, testFolder)

				// Configure scale parameters based on resource type
				// This is a placeholder - adjust based on actual resource scaling capabilities
				terraformOptions.Vars["instance_count"] = count
				
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

// BenchmarkMODULE_DISPLAY_NAME_PLACEHOLDERParallelCreation benchmarks parallel creation of MODULE_TYPE_PLACEHOLDER
func BenchmarkMODULE_DISPLAY_NAME_PLACEHOLDERParallelCreation(b *testing.B) {
	parallelCounts := []int{1, 2, 5, 10}

	for _, parallel := range parallelCounts {
		b.Run(fmt.Sprintf("Parallel_%d", parallel), func(b *testing.B) {
			b.SetParallelism(parallel)
			b.RunParallel(func(pb *testing.PB) {
				i := 0
				for pb.Next() {
					testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "MODULE_NAME_PLACEHOLDER/tests/fixtures/simple")
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

// TestMODULE_DISPLAY_NAME_PLACEHOLDERCreationTime validates creation time is within acceptable limits
func TestMODULE_DISPLAY_NAME_PLACEHOLDERCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "MODULE_NAME_PLACEHOLDER/tests/fixtures/simple")
	terraformOptions := getTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	// MODULE_TYPE_PLACEHOLDER creation should complete within 5 minutes
	// Adjust this based on the actual expected creation time for the resource
	maxDuration := 5 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"MODULE_DISPLAY_NAME_PLACEHOLDER creation took %v, expected less than %v", duration, maxDuration)

	t.Logf("MODULE_DISPLAY_NAME_PLACEHOLDER created in %v", duration)
}

// TestMODULE_DISPLAY_NAME_PLACEHOLDERScaling tests creating multiple MODULE_TYPE_PLACEHOLDER instances
func TestMODULE_DISPLAY_NAME_PLACEHOLDERScaling(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping scaling test in short mode")
	}

	instanceCount := 3
	creationTimes := make([]time.Duration, instanceCount)

	// Create multiple instances sequentially
	for i := 0; i < instanceCount; i++ {
		testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "MODULE_NAME_PLACEHOLDER/tests/fixtures/simple")
		terraformOptions := getTerraformOptions(t, testFolder)
		// Override the random_suffix for each iteration
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("scale%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])

		start := time.Now()
		terraform.InitAndApply(t, terraformOptions)
		creationTimes[i] = time.Since(start)

		// Cleanup immediately to avoid hitting limits
		terraform.Destroy(t, terraformOptions)

		t.Logf("MODULE_DISPLAY_NAME_PLACEHOLDER instance %d created in %v", i, creationTimes[i])
	}

	// Calculate average creation time
	var totalTime time.Duration
	for _, duration := range creationTimes {
		totalTime += duration
	}
	avgTime := totalTime / time.Duration(instanceCount)

	t.Logf("Average creation time for %d MODULE_TYPE_PLACEHOLDER instances: %v", instanceCount, avgTime)

	// Ensure average time is reasonable (under 3 minutes)
	// Adjust based on expected resource creation time
	require.LessOrEqual(t, avgTime, 3*time.Minute,
		"Average creation time %v exceeds maximum of 3 minutes", avgTime)
}

// TestMODULE_DISPLAY_NAME_PLACEHOLDERUpdatePerformance tests update performance
func TestMODULE_DISPLAY_NAME_PLACEHOLDERUpdatePerformance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "MODULE_NAME_PLACEHOLDER/tests/fixtures/simple")
	terraformOptions := getTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	// Initial deployment
	terraform.InitAndApply(t, terraformOptions)

	// Measure update times for different changes
	updateScenarios := []struct {
		name   string
		update map[string]interface{}
	}{
		{
			name: "UpdateTags",
			update: map[string]interface{}{
				"tags": map[string]interface{}{
					"Environment": "Test",
					"Updated":     "true",
				},
			},
		},
		{
			name: "UpdateConfiguration",
			update: map[string]interface{}{
				"enable_monitoring": true,
			},
		},
		// Add more update scenarios specific to MODULE_TYPE_PLACEHOLDER
	}

	for _, scenario := range updateScenarios {
		t.Run(scenario.name, func(t *testing.T) {
			// Apply update
			for k, v := range scenario.update {
				terraformOptions.Vars[k] = v
			}

			start := time.Now()
			terraform.Apply(t, terraformOptions)
			updateTime := time.Since(start)

			t.Logf("%s completed in %v", scenario.name, updateTime)

			// Updates should complete within 2 minutes
			require.LessOrEqual(t, updateTime, 2*time.Minute,
				"%s took %v, expected less than 2 minutes", scenario.name, updateTime)
		})
	}
}

// TestMODULE_DISPLAY_NAME_PLACEHOLDERDestroyPerformance tests destroy performance
func TestMODULE_DISPLAY_NAME_PLACEHOLDERDestroyPerformance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "MODULE_NAME_PLACEHOLDER/tests/fixtures/simple")
	terraformOptions := getTerraformOptions(t, testFolder)

	// Create resource
	terraform.InitAndApply(t, terraformOptions)

	// Measure destroy time
	start := time.Now()
	terraform.Destroy(t, terraformOptions)
	destroyTime := time.Since(start)

	t.Logf("MODULE_DISPLAY_NAME_PLACEHOLDER destroyed in %v", destroyTime)

	// Destroy should complete within 3 minutes
	require.LessOrEqual(t, destroyTime, 3*time.Minute,
		"Destroy took %v, expected less than 3 minutes", destroyTime)
}