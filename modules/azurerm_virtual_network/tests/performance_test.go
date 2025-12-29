package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkVirtualNetworkCreationSimple benchmarks simple virtual network creation
func BenchmarkVirtualNetworkCreationSimple(b *testing.B) {
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, ".", "fixtures/basic")
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

// BenchmarkVirtualNetworkCreationWithSubnets benchmarks virtual network with different subnet counts
func BenchmarkVirtualNetworkCreationWithSubnets(b *testing.B) {
	b.ReportAllocs()

	subnetCounts := []int{1, 5, 10, 20}

	for _, count := range subnetCounts {
		b.Run(fmt.Sprintf("Subnets_%d", count), func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				b.StopTimer()
				testFolder := test_structure.CopyTerraformFolderToTemp(b, ".", "fixtures/basic")
				terraformOptions := getTerraformOptions(b, testFolder)

				// Generate subnets configuration
				subnets := make(map[string]map[string]interface{})
				for j := 0; j < count; j++ {
					subnets[fmt.Sprintf("subnet%d", j)] = map[string]interface{}{
						"address_prefixes": []string{fmt.Sprintf("10.0.%d.0/24", j)},
					}
				}
				terraformOptions.Vars["subnets"] = subnets
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
				b.ReportMetric(float64(count), "subnet_count")
			}
		})
	}
}

// BenchmarkVirtualNetworkCreationWithNSG benchmarks with different NSG rule configurations
func BenchmarkVirtualNetworkCreationWithNSG(b *testing.B) {
	b.ReportAllocs()

	ruleCounts := []int{0, 5, 10, 50}

	for _, count := range ruleCounts {
		b.Run(fmt.Sprintf("NSGRules_%d", count), func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				b.StopTimer()
				testFolder := test_structure.CopyTerraformFolderToTemp(b, ".", "fixtures/secure")
				terraformOptions := getTerraformOptions(b, testFolder)
				// Override the random_suffix for benchmarking
				terraformOptions.Vars["random_suffix"] = fmt.Sprintf("bench%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])
				terraformOptions.Vars["nsg_rule_count"] = count
				b.StartTimer()

				start := time.Now()
				terraform.InitAndApply(b, terraformOptions)
				creationTime := time.Since(start)

				b.StopTimer()
				terraform.Destroy(b, terraformOptions)
				b.StartTimer()

				b.ReportMetric(float64(creationTime.Milliseconds()), "creation_ms")
				b.ReportMetric(float64(count), "nsg_rule_count")
			}
		})
	}
}

// BenchmarkVirtualNetworkParallelCreation benchmarks parallel creation of virtual networks
func BenchmarkVirtualNetworkParallelCreation(b *testing.B) {
	parallelCounts := []int{1, 2, 5, 10}

	for _, parallel := range parallelCounts {
		b.Run(fmt.Sprintf("Parallel_%d", parallel), func(b *testing.B) {
			b.SetParallelism(parallel)
			b.RunParallel(func(pb *testing.PB) {
				i := 0
				for pb.Next() {
					testFolder := test_structure.CopyTerraformFolderToTemp(b, ".", "fixtures/basic")
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

// TestVirtualNetworkCreationTime validates creation time is within acceptable limits
func TestVirtualNetworkCreationTime(t *testing.T) {
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

	// Virtual network creation should complete within 5 minutes
	maxDuration := 5 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"Virtual network creation took %v, expected less than %v", duration, maxDuration)

	t.Logf("Virtual network created in %v", duration)
}

// TestVirtualNetworkScaling tests creating multiple virtual networks
func TestVirtualNetworkScaling(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping scaling test in short mode")
	}

	networkCount := 5
	creationTimes := make([]time.Duration, networkCount)

	// Create multiple virtual networks sequentially
	for i := 0; i < networkCount; i++ {
		testFolder := test_structure.CopyTerraformFolderToTemp(t, ".", "fixtures/basic")
		terraformOptions := getTerraformOptions(t, testFolder)
		// Override the random_suffix for each iteration
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("scale%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])

		start := time.Now()
		terraform.InitAndApply(t, terraformOptions)
		creationTimes[i] = time.Since(start)

		// Cleanup immediately to avoid hitting limits
		terraform.Destroy(t, terraformOptions)

		t.Logf("Virtual network %d created in %v", i, creationTimes[i])
	}

	// Calculate average creation time
	var totalTime time.Duration
	for _, duration := range creationTimes {
		totalTime += duration
	}
	avgTime := totalTime / time.Duration(networkCount)

	t.Logf("Average creation time for %d virtual networks: %v", networkCount, avgTime)

	// Ensure average time is reasonable (under 3 minutes)
	require.LessOrEqual(t, avgTime, 3*time.Minute,
		"Average creation time %v exceeds maximum of 3 minutes", avgTime)
}