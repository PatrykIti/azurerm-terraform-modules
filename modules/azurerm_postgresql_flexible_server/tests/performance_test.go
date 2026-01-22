package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkPostgresqlFlexibleServerCreationSimple benchmarks simple postgresql_flexible_server creation
func BenchmarkPostgresqlFlexibleServerCreationSimple(b *testing.B) {
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, ".", "fixtures/basic")
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

// BenchmarkPostgresqlFlexibleServerCreationWithFeatures benchmarks different SKU sizes
func BenchmarkPostgresqlFlexibleServerCreationWithFeatures(b *testing.B) {
	b.ReportAllocs()

	featureConfigs := []struct {
		name    string
		skuName string
	}{
		{name: "Standard_D2s_v3", skuName: "Standard_D2s_v3"},
		{name: "Standard_D4s_v3", skuName: "Standard_D4s_v3"},
	}

	for _, fc := range featureConfigs {
		b.Run(fc.name, func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				b.StopTimer()
				testFolder := test_structure.CopyTerraformFolderToTemp(b, ".", "fixtures/basic")
				terraformOptions := getTerraformOptions(b, testFolder)
				terraformOptions.Vars["sku_name"] = fc.skuName
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

// BenchmarkPostgresqlFlexibleServerCreationWithScale benchmarks scaling scenarios
func BenchmarkPostgresqlFlexibleServerCreationWithScale(b *testing.B) {
	b.Skip("Scaling benchmarks are not applicable for a single-server resource")
}

// BenchmarkPostgresqlFlexibleServerParallelCreation benchmarks parallel creation of postgresql_flexible_server
func BenchmarkPostgresqlFlexibleServerParallelCreation(b *testing.B) {
	parallelCounts := []int{1, 2, 5, 10}

	for _, parallel := range parallelCounts {
		b.Run(fmt.Sprintf("Parallel_%d", parallel), func(b *testing.B) {
			b.SetParallelism(parallel)
			b.RunParallel(func(pb *testing.PB) {
				i := 0
				for pb.Next() {
					testFolder := test_structure.CopyTerraformFolderToTemp(b, ".", "fixtures/basic")
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

// TestPostgresqlFlexibleServerCreationTime validates creation time is within acceptable limits
func TestPostgresqlFlexibleServerCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	maxDuration := 5 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"PostgreSQL Flexible Server creation took %v, expected less than %v", duration, maxDuration)

	t.Logf("PostgreSQL Flexible Server created in %v", duration)
}

// TestPostgresqlFlexibleServerScaling tests creating multiple postgresql_flexible_server instances
func TestPostgresqlFlexibleServerScaling(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping scaling test in short mode")
	}

	instanceCount := 3
	creationTimes := make([]time.Duration, instanceCount)

	for i := 0; i < instanceCount; i++ {
		testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/basic")
		terraformOptions := getTerraformOptions(t, testFolder)
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("scale%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])

		start := time.Now()
		terraform.InitAndApply(t, terraformOptions)
		creationTimes[i] = time.Since(start)

		terraform.Destroy(t, terraformOptions)

		t.Logf("PostgreSQL Flexible Server instance %d created in %v", i, creationTimes[i])
	}

	var totalTime time.Duration
	for _, duration := range creationTimes {
		totalTime += duration
	}
	avgTime := totalTime / time.Duration(instanceCount)

	t.Logf("Average creation time for %d postgresql_flexible_server instances: %v", instanceCount, avgTime)

	require.LessOrEqual(t, avgTime, 3*time.Minute,
		"Average creation time %v exceeds maximum of 3 minutes", avgTime)
}

// TestPostgresqlFlexibleServerUpdatePerformance tests update performance
func TestPostgresqlFlexibleServerUpdatePerformance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/basic")
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

// TestPostgresqlFlexibleServerDestroyPerformance tests destroy performance
func TestPostgresqlFlexibleServerDestroyPerformance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)

	terraform.InitAndApply(t, terraformOptions)

	start := time.Now()
	terraform.Destroy(t, terraformOptions)
	destroyTime := time.Since(start)

	t.Logf("PostgreSQL Flexible Server destroyed in %v", destroyTime)

	require.LessOrEqual(t, destroyTime, 3*time.Minute,
		"Destroy took %v, expected less than 3 minutes", destroyTime)
}
