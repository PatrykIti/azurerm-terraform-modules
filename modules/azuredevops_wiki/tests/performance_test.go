package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsWikiCreation(b *testing.B) {
	b.Skip("Azure DevOps wiki benchmarks are not enabled")
}
