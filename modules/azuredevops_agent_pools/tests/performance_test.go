package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsAgentPoolsCreation(b *testing.B) {
	b.Skip("Azure DevOps agent pools benchmarks are not enabled")
}
