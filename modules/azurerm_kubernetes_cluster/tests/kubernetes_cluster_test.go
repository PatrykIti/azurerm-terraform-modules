package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test basic AKS cluster creation
func TestBasicKubernetesCluster(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_cluster/tests/fixtures/basic")

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
		assert.Equal(t, "SystemAssigned", *cluster.Identity.Type)
		assert.Equal(t, "standard", string(*cluster.Properties.NetworkProfile.LoadBalancerSKU))
		assert.Equal(t, int32(1), *(*cluster.Properties.AgentPoolProfiles[0]).Count)
	})
}

// Test a more complete AKS cluster configuration
func TestCompleteKubernetesCluster(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_cluster/tests/fixtures/complete")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		// The 'complete' fixture requires a log_analytics_workspace_id, which we are creating within the fixture itself.
		// We pass a placeholder here, which will be overridden by the fixture's own resource creation.
		terraformOptions.Vars["log_analytics_workspace_id"] = "placeholder"
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
		assert.NotNil(t, cluster.Properties.AddonProfiles["omsagent"])
		assert.True(t, *cluster.Properties.AddonProfiles["omsagent"].Enabled)
	})
}

// Test a security-hardened AKS cluster
func TestSecureKubernetesCluster(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_cluster/tests/fixtures/secure")

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

		assert.True(t, *cluster.Properties.APIServerAccessProfile.EnablePrivateCluster)
		assert.NotNil(t, cluster.Properties.AddonProfiles["azurepolicy"])
		assert.True(t, *cluster.Properties.AddonProfiles["azurepolicy"].Enabled)
	})
}

// Negative test cases for validation rules
func TestKubernetesClusterValidationRules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		vars          map[string]interface{}
		expectedError string
	}{
		{
			name: "InvalidName",
			vars: map[string]interface{}{
				"cluster_name": "AKS-Invalid-Name",
			},
			expectedError: "only lowercase alphanumeric characters and hyphens are allowed, and must start and end with a letter or number",
		},
	}

	for _, tc := range testCases {
		tc := tc // capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_cluster/tests/fixtures/negative")
			
			// Merge the random_suffix with the test case variables
			vars := getTerraformOptions(t, testFolder).Vars
			for k, v := range tc.vars {
				vars[k] = v
			}

			terraformOptions := &terraform.Options{
				TerraformDir: testFolder,
				Vars:         vars,
				NoColor:      true,
			}

			_, err := terraform.InitAndPlanE(t, terraformOptions)
			require.Error(t, err)
			assert.Contains(t, err.Error(), tc.expectedError)
		})
	}
}