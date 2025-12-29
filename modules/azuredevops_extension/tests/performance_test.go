package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsExtensionCreation(b *testing.B) {
	b.Skip("Azure DevOps extension benchmarks are not enabled")
}
