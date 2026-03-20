package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestKubernetesClusterRoleBindingLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping lifecycle test in short mode")
	}
	t.Parallel()
	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_cluster_role_binding/tests/fixtures/basic")
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})
	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		applyWithClusterFirst(t, terraformOptions)
	})
	test_structure.RunTestStage(t, "validate_and_reapply", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		name := terraform.Output(t, terraformOptions, "cluster_role_binding_name")
		assert.Equal(t, "namespace-reader-user", name)
		terraform.Apply(t, terraformOptions)
		assert.Equal(t, name, terraform.Output(t, terraformOptions, "cluster_role_binding_name"))
	})
}
