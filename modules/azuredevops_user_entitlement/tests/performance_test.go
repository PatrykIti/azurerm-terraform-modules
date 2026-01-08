package test

import "testing"

func BenchmarkAzuredevopsUserEntitlement(b *testing.B) {
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}
	b.Skip("Azure DevOps entitlement benchmarks are not enabled")
}
