package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
)

// BenchmarkPostgresqlFlexibleServerDatabaseCreation benchmarks the creation of a basic database.
func BenchmarkPostgresqlFlexibleServerDatabaseCreation(b *testing.B) {
	if testing.Short() {
		b.Skip("Skipping benchmark in short mode")
	}

	for i := 0; i < b.N; i++ {
		b.StopTimer()
		testFolder := test_structure.CopyTerraformFolderToTemp(b, "../..", "azurerm_postgresql_flexible_server_database/tests/fixtures/basic")
		terraformOptions := getTerraformOptions(b, testFolder)
		b.StartTimer()

		terraform.InitAndApply(b, terraformOptions)

		b.StopTimer()
		terraform.Destroy(b, terraformOptions)
	}
}

// TestPostgresqlFlexibleServerDatabaseCreationTime validates creation time is within the SLA.
func TestPostgresqlFlexibleServerDatabaseCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_postgresql_flexible_server_database/tests/fixtures/basic")
	terraformOptions := getTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	maxDuration := 5 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"PostgreSQL Flexible Server Database creation took %v, expected less than %v", duration, maxDuration)
}
