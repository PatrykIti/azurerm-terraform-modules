package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// TestMonitorDataCollectionRuleCreationTime validates creation time is within acceptable limits.
func TestMonitorDataCollectionRuleCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_monitor_data_collection_rule/tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)

	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	terraform.Destroy(t, terraformOptions)

	maxDuration := 10 * time.Minute
	require.LessOrEqual(t, duration, maxDuration, "Data Collection Rule creation took too long")
}
