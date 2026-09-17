package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestKubernetesRoleLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping lifecycle test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_role/tests/fixtures/basic")

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
		roleName := terraform.Output(t, terraformOptions, "role_name")
		assert.Equal(t, "intent-resolver-read", roleName)

		terraform.Apply(t, terraformOptions)
		roleNameAfter := terraform.Output(t, terraformOptions, "role_name")
		assert.Equal(t, roleName, roleNameAfter)
	})
}
