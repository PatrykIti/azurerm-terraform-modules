# Terratest File Structure

Maintaining a consistent and logical file structure in the `tests` directory is crucial for the readability, scalability, and maintainability of integration tests. The following pattern, based on the implementation in the `azurerm_storage_account` module, is the standard for all modules in this repository.

## Standard `tests` Directory Structure

```
tests/
├── fixtures/                    # Terraform configurations for various test scenarios
│   ├── simple/                  # Minimal, basic configuration
│   ├── complete/                # Configuration with all features
│   ├── security/                # Security-focused configuration
│   ├── network/                 # Network scenarios
│   ├── private_endpoint/        # Tests using Private Endpoint
│   └── negative/                # Scenarios intended to fail
├── unit/                        # Unit tests (Native Terraform Tests)
├── go.mod                       # Go module definition and dependencies
├── go.sum                       # Dependency checksums
├── Makefile                     # Helper scripts for running tests
├── storage_account_test.go      # Main tests for basic scenarios
├── integration_test.go          # More complex integration and lifecycle tests
├── performance_test.go          # Performance tests and benchmarks
├── test_helpers.go              # Helper functions, validation, and Azure SDK clients
├── test_config.yaml             # Test suite configuration for CI/CD
├── test_env.sh                  # Script for setting environment variables
├── run_tests_parallel.sh        # Script for running tests in parallel
├── run_tests_sequential.sh      # Script for running tests sequentially
└── test_outputs/                # Directory for test results (ignored by Git)
    └── .gitkeep
```

## Detailed Description of Go Files

### 1. `{module_name}_test.go` (e.g., `storage_account_test.go`)

-   **Purpose**: The main test file for the module. It contains tests for the most basic and important scenarios.
-   **Contents**:
    -   Test functions (`Test...`) for each main `fixture`, e.g., `TestBasicStorageAccount`, `TestCompleteStorageAccount`, `TestStorageAccountSecurity`.
    -   Each test function should be independent and use `t.Parallel()`.
    -   Orchestration of the test lifecycle: `Setup` -> `Deploy` -> `Validate` -> `Cleanup` using `test_structure`.
    -   Basic assertions on Terraform output values.
    -   Calls to more detailed validation functions from `test_helpers.go`.

**Example (`storage_account_test.go`):**
```go
func TestBasicStorageAccount(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/simple")
	
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
		// ... further validation
	})
}
```

### 2. `integration_test.go`

-   **Purpose**: Contains more advanced tests that check the integration of different features, the resource lifecycle, or specific scenarios.
-   **Contents**:
    -   `lifecycle` tests: Checking that `terraform apply` on the same configuration causes no changes (idempotency) and that resource updates work correctly.
    -   `Disaster Recovery` scenario tests, e.g., verifying `RA-GRS`.
    -   `compliance` tests that verify a set of security rules.
    -   Tests that may require longer execution time and are marked to be skipped in `short` mode (`if testing.Short() { t.Skip(...) }`).

**Example (`integration_test.go`):**
```go
func TestStorageAccountLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	// ...
	// 1. Initial deployment
	terraform.InitAndApply(t, terraformOptions)
	
	// 2. Update configuration
	terraformOptions.Vars["enable_blob_versioning"] = true
	terraform.Apply(t, terraformOptions)

	// 3. Verify update
	helper.ValidateBlobServiceProperties(t, storageAccountName, resourceGroupName)
}
```

### 3. `performance_test.go`

-   **Purpose**: Contains performance tests and benchmarks.
-   **Contents**:
    -   Go benchmarks (`Benchmark...`) to measure the creation time of resources in different configurations.
    -   Tests validating that the resource creation time is within acceptable limits (e.g., under 5 minutes).
    -   Scalability tests, e.g., creating multiple resources in parallel.
    -   All tests in this file should be skipped in `short` mode.

**Example (`performance_test.go`):**
```go
func BenchmarkStorageAccountCreationSimple(b *testing.B) {
	for i := 0; i < b.N; i++ {
		b.StopTimer()
		// ... setup
		b.StartTimer()

		start := time.Now()
		terraform.InitAndApply(b, terraformOptions)
		creationTime := time.Since(start)

		b.StopTimer()
		terraform.Destroy(b, terraformOptions)
		b.StartTimer()

		b.ReportMetric(float64(creationTime.Milliseconds()), "creation_ms")
	}
}
```

### 4. `test_helpers.go`

-   **Purpose**: A central place for shared helper functions to avoid code duplication (`DRY`).
-   **Contents**:
    -   **Helper Class**: A pattern where we create a struct (e.g., `StorageAccountHelper`) that stores Azure SDK clients and logic specific to a given resource.
    -   **Initializer Functions**: `NewStorageAccountHelper` to create an instance of the helper and initialize SDK clients.
    -   **Validation Functions**: `ValidateStorageAccountEncryption`, `ValidateNetworkRules` - functions that take an SDK resource object and perform assertions on it.
    -   **Waiter Functions**: `WaitForStorageAccountReady`, `WaitForGRSSecondaryEndpoints` - functions that use a `retry` loop to wait for a resource to reach a desired state.
    -   **Terratest Helper Functions**: `getTerraformOptions` - a factory function to create a consistent `terraform.Options` configuration for all tests.

This file is the heart of the integration tests, and its good organization is key. It will be discussed in detail in the next section.