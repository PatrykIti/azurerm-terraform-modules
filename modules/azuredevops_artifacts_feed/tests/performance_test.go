package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsArtifactsFeedCreation(b *testing.B) {
	b.Skip("Azure DevOps artifacts feed benchmarks are not enabled")
}
