package test

import "testing"

func TestAzuredevopsProjectPermissionsPerformance(t *testing.T) {
	if testing.Short() {
		t.Skip("Azure DevOps project permissions benchmarks are not enabled")
	}

	t.Skip("Performance tests are not implemented for this module")
}
