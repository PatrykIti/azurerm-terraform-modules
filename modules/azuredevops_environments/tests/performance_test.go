package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsEnvironmentsCreation(b *testing.B) {
	b.Skip("Azure DevOps environments benchmarks are not enabled")
}
