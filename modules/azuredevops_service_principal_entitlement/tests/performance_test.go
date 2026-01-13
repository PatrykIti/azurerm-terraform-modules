package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsServicePrincipalEntitlement(b *testing.B) {
	if testing.Short() {
		b.Skip("Skipping benchmarks in short mode")
	}
	b.Skip("Azure DevOps service principal entitlement benchmarks are not enabled")
}
