package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsRepositoryCreation(b *testing.B) {
	b.Skip("Azure DevOps repository benchmarks are not enabled")
}
