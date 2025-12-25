package test

import "testing"

// Benchmarks are intentionally disabled by default for Azure DevOps provider modules.
func BenchmarkAzuredevopsVariableGroupsCreation(b *testing.B) {
	b.Skip("Azure DevOps variable groups benchmarks are not enabled")
}
