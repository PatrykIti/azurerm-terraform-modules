package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

func TestKubernetesClusterRoleBindingCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()
	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_cluster_role_binding/tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)
	start := time.Now()
	applyWithClusterFirst(t, terraformOptions)
	duration := time.Since(start)
	require.LessOrEqual(t, duration, 25*time.Minute, "Kubernetes cluster role binding creation took %v", duration)
}
