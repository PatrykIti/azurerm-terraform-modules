package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// BenchmarkVirtualNetworkCreation benchmarks the creation time of a Virtual Network
func BenchmarkVirtualNetworkCreation(b *testing.B) {
	// Skip if not running benchmarks
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	for i := 0; i < b.N; i++ {
		b.StopTimer()

		// Setup unique resource names for each iteration
		uniqueID := fmt.Sprintf("%d%d", time.Now().Unix(), i)
		terraformOptions := getTerraformOptionsWithVars(b, "./fixtures/basic", map[string]interface{}{
			"random_suffix": uniqueID,
		})

		b.StartTimer()

		// Time the apply operation
		start := time.Now()
		terraform.InitAndApply(b, terraformOptions)
		duration := time.Since(start)

		b.StopTimer()

		// Clean up
		terraform.Destroy(b, terraformOptions)

		// Log the duration
		b.Logf("Virtual Network creation took: %v", duration)

		// Reset timer for next iteration
		b.ResetTimer()
	}
}

// TestVirtualNetworkScaling tests creating multiple Virtual Networks in parallel
func TestVirtualNetworkScaling(t *testing.T) {
	t.Parallel()

	if testing.Short() {
		t.Skip("Skipping scaling test in short mode")
	}

	// Number of Virtual Networks to create in parallel
	numVirtualNetworks := 3

	// Channel to collect results
	results := make(chan error, numVirtualNetworks)

	// Create Virtual Networks in parallel
	for i := 0; i < numVirtualNetworks; i++ {
		go func(index int) {
			uniqueID := fmt.Sprintf("%d%d", time.Now().Unix(), index)
			terraformOptions := getTerraformOptionsWithVars(t, "./fixtures/basic", map[string]interface{}{
				"random_suffix": uniqueID,
				"name_prefix":   fmt.Sprintf("vnet%d", index),
			})

			defer terraform.Destroy(t, terraformOptions)

			err := terraform.InitAndApplyE(t, terraformOptions)
			results <- err
		}(i)
	}

	// Collect results
	var errors []error
	for i := 0; i < numVirtualNetworks; i++ {
		if err := <-results; err != nil {
			errors = append(errors, err)
		}
	}

	// Assert no errors occurred
	assert.Empty(t, errors, "Expected no errors during parallel Virtual Network creation")
}

// TestVirtualNetworkCreationTime tests that Virtual Network creation completes within expected time
func TestVirtualNetworkCreationTime(t *testing.T) {
	t.Parallel()

	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}

	terraformOptions := getTerraformOptions(t, "./fixtures/basic")

	defer terraform.Destroy(t, terraformOptions)

	// Initialize
	terraform.Init(t, terraformOptions)

	// Time the apply operation
	start := time.Now()
	terraform.Apply(t, terraformOptions)
	duration := time.Since(start)

	// Assert creation time is within expected bounds (5 minutes)
	maxDuration := 5 * time.Minute
	assert.LessOrEqual(t, duration, maxDuration, 
		"Virtual Network creation took longer than expected: %v", duration)

	t.Logf("Virtual Network creation completed in: %v", duration)
}

// TestVirtualNetworkLargeAddressSpace tests Virtual Network with large address spaces
func TestVirtualNetworkLargeAddressSpace(t *testing.T) {
	t.Parallel()

	if testing.Short() {
		t.Skip("Skipping large address space test in short mode")
	}

	// Test with multiple large address spaces
	addressSpaces := []string{
		"10.0.0.0/8",
		"172.16.0.0/12",
		"192.168.0.0/16",
	}

	terraformOptions := getTerraformOptionsWithVars(t, "./fixtures/basic", map[string]interface{}{
		"address_space": addressSpaces,
	})

	defer terraform.Destroy(t, terraformOptions)

	// Time the operation
	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	// Verify outputs
	outputAddressSpace := terraform.OutputList(t, terraformOptions, "virtual_network_address_space")
	assert.Len(t, outputAddressSpace, len(addressSpaces))

	t.Logf("Virtual Network with %d address spaces created in: %v", len(addressSpaces), duration)
}