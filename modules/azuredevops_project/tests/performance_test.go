package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsProjectCreation(b *testing.B) {
	b.Skip("Azure DevOps project benchmarks are not enabled")
}
