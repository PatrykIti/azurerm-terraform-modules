package test

import (
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/containerservice/armcontainerservice"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// Test basic AKS cluster creation
func TestBasicKubernetesCluster(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "modules/azurerm_kubernetes_cluster/tests/fixtures/basic")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		helper := NewKubernetesClusterHelper(t)

		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		clusterName := terraform.Output(t, terraformOptions, "kubernetes_cluster_name")

		cluster := helper.GetKubernetesClusterProperties(t, resourceGroupName, clusterName)

		assert.Equal(t, "Succeeded", string(*cluster.Properties.ProvisioningState))
		assert.Equal(t, "System", *cluster.Properties.Identity.Type)
		assert.Equal(t, "Standard", string(*cluster.Properties.NetworkProfile.LoadBalancerSKU))
	})
}

// Test a more complete AKS cluster configuration
func TestCompleteKubernetesCluster(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "modules/azurerm_kubernetes_cluster/tests/fixtures/complete")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		helper := NewKubernetesClusterHelper(t)

		resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
		clusterName := terraform.Output(t, terraformOptions, "kubernetes_cluster_name")

		cluster := helper.GetKubernetesClusterProperties(t, resourceGroupName, clusterName)

		assert.Equal(t, "Succeeded", string(*cluster.Properties.ProvisioningState))
		assert.True(t, *cluster.Properties.APIServerAccessProfile.EnablePrivateCluster)
		assert.NotNil(t, cluster.Properties.AddonProfiles["azurepolicy"])
		assert.True(t, *cluster.Properties.AddonProfiles["azurepolicy"].Enabled)
	})
}
