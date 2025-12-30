package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestKubernetesClusterLifecycle tests the update and idempotency of the AKS module
func TestKubernetesClusterLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping lifecycle test in short mode")
	}

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "tests/fixtures/basic")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	// Deploy initial version
	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	// Validate initial deployment and then update
	test_structure.RunTestStage(t, "validate_and_update", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		helper := NewKubernetesClusterHelper(t)

		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		clusterName := terraform.Output(t, terraformOptions, "kubernetes_cluster_name")

		// Validate initial node count
		cluster := helper.GetKubernetesClusterProperties(t, resourceGroupName, clusterName)
		assert.Equal(t, int32(1), *(*cluster.Properties.AgentPoolProfiles[0]).Count)

		// Update the node count
		terraformOptions.Vars["node_count"] = 2
		terraform.Apply(t, terraformOptions)

		// Validate the updated node count
		clusterAfterUpdate := helper.GetKubernetesClusterProperties(t, resourceGroupName, clusterName)
		assert.Equal(t, int32(2), *(*clusterAfterUpdate.Properties.AgentPoolProfiles[0]).Count)

		// Run apply again to check for idempotency
		terraform.Apply(t, terraformOptions)
	})
}
