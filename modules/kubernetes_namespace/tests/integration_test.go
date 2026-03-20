package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestKubernetesNamespaceLifecycle validates idempotency for the basic fixture
func TestKubernetesNamespaceLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping lifecycle test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_namespace/tests/fixtures/basic")

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

		namespaceName := terraform.Output(t, terraformOptions, "namespace_name")
		assert.Equal(t, "app", namespaceName)

		terraform.Apply(t, terraformOptions)

		namespaceNameAfter := terraform.Output(t, terraformOptions, "namespace_name")
		assert.Equal(t, namespaceName, namespaceNameAfter)
	})
}
