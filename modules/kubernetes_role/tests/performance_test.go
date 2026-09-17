package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

func TestKubernetesRoleCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "kubernetes_role/tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	start := time.Now()
	applyWithClusterFirst(t, terraformOptions)
	duration := time.Since(start)

	maxDuration := 25 * time.Minute
	require.LessOrEqual(t, duration, maxDuration, "Kubernetes role creation took %v, expected less than %v", duration, maxDuration)
}
