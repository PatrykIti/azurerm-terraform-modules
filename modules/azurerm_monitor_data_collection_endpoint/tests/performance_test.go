package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// TestMonitorDataCollectionEndpointCreationTime validates creation time is within acceptable limits.
func TestMonitorDataCollectionEndpointCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)

	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	terraform.Destroy(t, terraformOptions)

	maxDuration := 10 * time.Minute
	require.LessOrEqual(t, duration, maxDuration, "Data Collection Endpoint creation took too long")
}
