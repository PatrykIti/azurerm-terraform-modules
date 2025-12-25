package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsServicehooksCreation(b *testing.B) {
	b.Skip("Azure DevOps service hooks benchmarks are not enabled")
}
