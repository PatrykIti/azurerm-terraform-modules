package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkRouteTableCreation benchmarks the creation of a basic Route Table
func BenchmarkRouteTableCreation(b *testing.B) {
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, ".", "fixtures/basic")
		terraformOptions := getTerraformOptions(b, testFolder)
		b.StartTimer()

		terraform.InitAndApply(b, terraformOptions)

		b.StopTimer()
		terraform.Destroy(b, terraformOptions)
	}
}

// TestRouteTableCreationTime validates that the route table creation time is within the SLA
func TestRouteTableCreationTime(t *testing.T) {
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

	// Route Table creation should be relatively fast, so we set an SLA of 5 minutes.
	maxDuration := 5 * time.Minute
	require.LessOrEqual(t, duration, maxDuration, "Route Table creation took %v, which is longer than the SLA of %v", duration, maxDuration)
}