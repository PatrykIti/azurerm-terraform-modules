package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsWorkItemsCreation(b *testing.B) {
	b.Skip("Azure DevOps work items benchmarks are not enabled")
}
