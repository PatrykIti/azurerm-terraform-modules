package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsPipelinesCreation(b *testing.B) {
	b.Skip("Azure DevOps pipelines benchmarks are not enabled")
}
