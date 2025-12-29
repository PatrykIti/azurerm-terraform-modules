package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsServiceendpointCreation(b *testing.B) {
	b.Skip("Azure DevOps service endpoint benchmarks are not enabled")
}
