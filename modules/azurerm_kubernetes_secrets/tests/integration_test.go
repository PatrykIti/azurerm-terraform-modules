package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestKubernetesSecretsLifecycle validates idempotency for the basic fixture
func TestKubernetesSecretsLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping lifecycle test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_secrets/tests/fixtures/basic")

	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate_and_reapply", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)

		strategy := terraform.Output(t, terraformOptions, "strategy")
		secretName := terraform.Output(t, terraformOptions, "kubernetes_secret_name")

		assert.Equal(t, "manual", strategy)
		assert.NotEmpty(t, secretName)

		terraform.Apply(t, terraformOptions)

		secretNameAfter := terraform.Output(t, terraformOptions, "kubernetes_secret_name")
		assert.Equal(t, secretName, secretNameAfter)
	})
}
