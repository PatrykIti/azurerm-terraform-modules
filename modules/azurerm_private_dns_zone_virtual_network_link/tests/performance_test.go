package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkPrivateDnsZoneVirtualNetworkLinkCreationSimple benchmarks simple private_dns_zone_virtual_network_link creation
func BenchmarkPrivateDnsZoneVirtualNetworkLinkCreationSimple(b *testing.B) {
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

// BenchmarkPrivateDnsZoneVirtualNetworkLinkCreationWithFeatures benchmarks private_dns_zone_virtual_network_link with various features
func BenchmarkPrivateDnsZoneVirtualNetworkLinkCreationWithFeatures(b *testing.B) {
	b.ReportAllocs()

	// Define different feature configurations to benchmark
	featureConfigs := []struct {
		name string
		tags map[string]interface{}
	}{
		{
			name: "Basic",
			tags: nil,
		},
		{
			name: "WithTags",
			tags: map[string]interface{}{
				"Environment": "Test",
				"Feature":     "Tagged",
			},
		},
	}

	for _, fc := range featureConfigs {
		b.Run(fc.name, func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				b.StopTimer()
				testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
				terraformOptions := getTerraformOptions(b, testFolder)

				if fc.tags != nil {
					terraformOptions.Vars["tags"] = fc.tags
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

// BenchmarkPrivateDnsZoneVirtualNetworkLinkCreationWithScale benchmarks with different scale configurations
func BenchmarkPrivateDnsZoneVirtualNetworkLinkCreationWithScale(b *testing.B) {
	b.ReportAllocs()

	// Define different scale configurations
	scaleCounts := []int{1, 5, 10, 20}

	for _, count := range scaleCounts {
		b.Run(fmt.Sprintf("Scale_%d", count), func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				b.StopTimer()
				testFolder := test_structure.CopyTerraformFolderToTemp(b, "..", "tests/fixtures/basic")
				terraformOptions := getTerraformOptions(b, testFolder)

				terraformOptions.Vars["tags"] = map[string]interface{}{
					"ScaleCount": fmt.Sprintf("%d", count),
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
				b.ReportMetric(float64(count), "scale_count")
			}
		})
	}
}

// BenchmarkPrivateDnsZoneVirtualNetworkLinkParallelCreation benchmarks parallel creation of private_dns_zone_virtual_network_link
func BenchmarkPrivateDnsZoneVirtualNetworkLinkParallelCreation(b *testing.B) {
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

// TestPrivateDnsZoneVirtualNetworkLinkCreationTime validates creation time is within acceptable limits
func TestPrivateDnsZoneVirtualNetworkLinkCreationTime(t *testing.T) {
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

	// private_dns_zone_virtual_network_link creation should complete within 5 minutes
	// Adjust this based on the actual expected creation time for the resource
	maxDuration := 5 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"Private DNS Zone Virtual Network Link creation took %v, expected less than %v", duration, maxDuration)

	t.Logf("Private DNS Zone Virtual Network Link created in %v", duration)
}

// TestPrivateDnsZoneVirtualNetworkLinkScaling tests creating multiple private_dns_zone_virtual_network_link instances
func TestPrivateDnsZoneVirtualNetworkLinkScaling(t *testing.T) {
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

		t.Logf("Private DNS Zone Virtual Network Link instance %d created in %v", i, creationTimes[i])
	}

	// Calculate average creation time
	var totalTime time.Duration
	for _, duration := range creationTimes {
		totalTime += duration
	}
	avgTime := totalTime / time.Duration(instanceCount)

	t.Logf("Average creation time for %d private_dns_zone_virtual_network_link instances: %v", instanceCount, avgTime)

	// Ensure average time is reasonable (under 3 minutes)
	// Adjust based on expected resource creation time
	require.LessOrEqual(t, avgTime, 3*time.Minute,
		"Average creation time %v exceeds maximum of 3 minutes", avgTime)
}

// TestPrivateDnsZoneVirtualNetworkLinkUpdatePerformance tests update performance
func TestPrivateDnsZoneVirtualNetworkLinkUpdatePerformance(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
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

// TestPrivateDnsZoneVirtualNetworkLinkDestroyPerformance tests destroy performance
func TestPrivateDnsZoneVirtualNetworkLinkDestroyPerformance(t *testing.T) {
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

	t.Logf("Private DNS Zone Virtual Network Link destroyed in %v", destroyTime)

	// Destroy should complete within 3 minutes
	require.LessOrEqual(t, destroyTime, 3*time.Minute,
		"Destroy took %v, expected less than 3 minutes", destroyTime)
}
