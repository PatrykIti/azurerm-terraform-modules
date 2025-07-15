package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkStorageAccountCreationSimple benchmarks simple storage account creation
func BenchmarkStorageAccountCreationSimple(b *testing.B) {
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "azurerm_storage_account/tests/fixtures/simple")
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

// BenchmarkStorageAccountCreationWithContainers benchmarks storage account with containers
func BenchmarkStorageAccountCreationWithContainers(b *testing.B) {
	b.ReportAllocs()

	containerCounts := []int{1, 5, 10, 20}

	for _, count := range containerCounts {
		b.Run(fmt.Sprintf("Containers_%d", count), func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				b.StopTimer()
				testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "azurerm_storage_account/tests/fixtures/simple")
				terraformOptions := getTerraformOptions(b, testFolder)

				// Generate containers configuration
				containers := make([]map[string]interface{}, count)
				for j := 0; j < count; j++ {
					containers[j] = map[string]interface{}{
						"name":                  fmt.Sprintf("container%d", j),
						"container_access_type": "private",
					}
				}
				terraformOptions.Vars["containers"] = containers
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
				b.ReportMetric(float64(count), "container_count")
			}
		})
	}
}

// BenchmarkStorageAccountCreationWithNetworkRules benchmarks with different network rule configurations
func BenchmarkStorageAccountCreationWithNetworkRules(b *testing.B) {
	b.ReportAllocs()

	ipRuleCounts := []int{0, 5, 10, 50}

	for _, count := range ipRuleCounts {
		b.Run(fmt.Sprintf("IPRules_%d", count), func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				b.StopTimer()
				testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "azurerm_storage_account/tests/fixtures/simple")
				terraformOptions := getTerraformOptions(b, testFolder)

				// Generate IP rules
				ipRules := make([]string, count)
				for j := 0; j < count; j++ {
					ipRules[j] = fmt.Sprintf("192.0.2.%d", j+1)
				}

				if count > 0 {
					terraformOptions.Vars["network_rules"] = map[string]interface{}{
						"default_action": "Deny",
						"ip_rules":       ipRules,
						"bypass":         "AzureServices",
					}
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
				b.ReportMetric(float64(count), "ip_rule_count")
			}
		})
	}
}

// BenchmarkStorageAccountParallelCreation benchmarks parallel creation of storage accounts
func BenchmarkStorageAccountParallelCreation(b *testing.B) {
	parallelCounts := []int{1, 2, 5, 10}

	for _, parallel := range parallelCounts {
		b.Run(fmt.Sprintf("Parallel_%d", parallel), func(b *testing.B) {
			b.SetParallelism(parallel)
			b.RunParallel(func(pb *testing.PB) {
				i := 0
				for pb.Next() {
					testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "azurerm_storage_account/tests/fixtures/simple")
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

// TestStorageAccountCreationTime validates creation time is within acceptable limits
func TestStorageAccountCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/simple")
	terraformOptions := getTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	// Storage account creation should complete within 5 minutes
	maxDuration := 5 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"Storage account creation took %v, expected less than %v", duration, maxDuration)

	t.Logf("Storage account created in %v", duration)
}

// TestStorageAccountScaling tests creating multiple storage accounts
func TestStorageAccountScaling(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping scaling test in short mode")
	}

	accountCount := 5
	creationTimes := make([]time.Duration, accountCount)

	// Create multiple storage accounts sequentially
	for i := 0; i < accountCount; i++ {
		testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/simple")
		terraformOptions := getTerraformOptions(t, testFolder)
		// Override the random_suffix for each iteration
		terraformOptions.Vars["random_suffix"] = fmt.Sprintf("scale%d%s", i, terraformOptions.Vars["random_suffix"].(string)[:5])

		start := time.Now()
		terraform.InitAndApply(t, terraformOptions)
		creationTimes[i] = time.Since(start)

		// Cleanup immediately to avoid hitting limits
		terraform.Destroy(t, terraformOptions)

		t.Logf("Storage account %d created in %v", i, creationTimes[i])
	}

	// Calculate average creation time
	var totalTime time.Duration
	for _, duration := range creationTimes {
		totalTime += duration
	}
	avgTime := totalTime / time.Duration(accountCount)

	t.Logf("Average creation time for %d storage accounts: %v", accountCount, avgTime)

	// Ensure average time is reasonable (under 3 minutes)
	require.LessOrEqual(t, avgTime, 3*time.Minute,
		"Average creation time %v exceeds maximum of 3 minutes", avgTime)
}
