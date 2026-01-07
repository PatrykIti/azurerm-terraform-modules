package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsIdentityCreation(b *testing.B) {
	b.Skip("Azure DevOps identity benchmarks are not enabled")
}
