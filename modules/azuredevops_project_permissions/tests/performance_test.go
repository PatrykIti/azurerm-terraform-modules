package test

import "testing"

func BenchmarkAzuredevopsProjectPermissions(b *testing.B) {
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	b.Skip("Azure DevOps project permissions benchmarks are not enabled")
}
