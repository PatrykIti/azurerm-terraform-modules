package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsTeamCreation(b *testing.B) {
	b.Skip("Azure DevOps team benchmarks are not enabled")
}
