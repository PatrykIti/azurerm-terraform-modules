package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkLogAnalyticsWorkspaceCreationSimple benchmarks simple log_analytics_workspace creation
func BenchmarkLogAnalyticsWorkspaceCreationSimple(b *testing.B) {
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

// BenchmarkLogAnalyticsWorkspaceCreationWithFeatures benchmarks different retention settings
func BenchmarkLogAnalyticsWorkspaceCreationWithFeatures(b *testing.B) {
	b.ReportAllocs()

	featureConfigs := []struct {
		name      string
		retention int
	}{
		{name: "Retention30", retention: 30},
		{name: "Retention90", retention: 90},
	}

	for _, fc := range featureConfigs {
		b.Run(fc.name, func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				b.StopTimer()
				testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
				terraformOptions := getTerraformOptions(b, testFolder)
				terraformOptions.Vars["retention_in_days"] = fc.retention
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

// BenchmarkLogAnalyticsWorkspaceCreationWithScale benchmarks scaling scenarios
func BenchmarkLogAnalyticsWorkspaceCreationWithScale(b *testing.B) {
	b.Skip("Scaling benchmarks are not applicable for a single workspace resource")
}

// BenchmarkLogAnalyticsWorkspaceParallelCreation benchmarks parallel creation of log_analytics_workspace
func BenchmarkLogAnalyticsWorkspaceParallelCreation(b *testing.B) {
	parallelCounts := []int{1, 2, 5, 10}

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

// TestLogAnalyticsWorkspaceCreationTime validates creation time is within acceptable limits
func TestLogAnalyticsWorkspaceCreationTime(t *testing.T) {
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

	maxDuration := 5 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"Log Analytics Workspace creation took %v, expected less than %v", duration, maxDuration)

	t.Logf("Log Analytics Workspace created in %v", duration)
}

// TestLogAnalyticsWorkspaceScaling tests creating multiple log_analytics_workspace instances
func TestLogAnalyticsWorkspaceScaling(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping scaling test in short mode")
	}

	instanceCount := 3
	creationTimes := make([]time.Duration, instanceCount)

	for i := 0; i < instanceCount; i++ {
		testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
		terraformOptions := getTerraformOptions(t, testFolder)
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("scale%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])

		start := time.Now()
		terraform.InitAndApply(t, terraformOptions)
		creationTimes[i] = time.Since(start)

		terraform.Destroy(t, terraformOptions)

		t.Logf("Log Analytics Workspace instance %d created in %v", i, creationTimes[i])
	}

	var totalTime time.Duration
	for _, duration := range creationTimes {
		totalTime += duration
	}
	avgTime := totalTime / time.Duration(instanceCount)

	t.Logf("Average creation time for %d log_analytics_workspace instances: %v", instanceCount, avgTime)

	require.LessOrEqual(t, avgTime, 5*time.Minute,
		"Average creation time %v exceeds maximum of 5 minutes", avgTime)
}

// TestLogAnalyticsWorkspaceUpdatePerformance tests update performance
func TestLogAnalyticsWorkspaceUpdatePerformance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

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
	}

	for _, scenario := range updateScenarios {
		t.Run(scenario.name, func(t *testing.T) {
			for k, v := range scenario.update {
				terraformOptions.Vars[k] = v
			}

			start := time.Now()
			terraform.Apply(t, terraformOptions)
			updateTime := time.Since(start)

			t.Logf("%s completed in %v", scenario.name, updateTime)

			require.LessOrEqual(t, updateTime, 2*time.Minute,
				"%s took %v, expected less than 2 minutes", scenario.name, updateTime)
		})
	}
}

// TestLogAnalyticsWorkspaceDestroyPerformance tests destroy performance
func TestLogAnalyticsWorkspaceDestroyPerformance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)

	terraform.InitAndApply(t, terraformOptions)

	start := time.Now()
	terraform.Destroy(t, terraformOptions)
	destroyTime := time.Since(start)

	t.Logf("Log Analytics Workspace destroyed in %v", destroyTime)

	require.LessOrEqual(t, destroyTime, 3*time.Minute,
		"Destroy took %v, expected less than 3 minutes", destroyTime)
}
