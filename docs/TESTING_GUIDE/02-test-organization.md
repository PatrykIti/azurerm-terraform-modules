# Test Organization & Structure

## Directory Structure Standards

All modules must follow a consistent directory structure for tests to ensure maintainability and discoverability. This structure separates unit tests, integration test configurations (`fixtures`), and the Go source files for integration tests.

### Complete Module Test Structure

The following is the standard directory structure, based on the `azurerm_kubernetes_cluster` module:

```
tests/
├── fixtures/                    # Terraform configurations for various test scenarios
│   ├── basic/                   # Minimal, basic configuration
│   ├── complete/                # Configuration with all features
│   ├── secure/                  # Security-focused configuration
│   ├── network/                 # Network scenarios
│   ├── negative/                # Scenarios intended to fail (e.g., invalid names)
│   └── <feature-specific>/      # Optional feature scenarios
├── unit/                        # Native Terraform tests (`.tftest.hcl`)
│   ├── node_pools.tftest.hcl    # Conditional logic for sub-resources
│   ├── api_server_validation.tftest.hcl
│   ├── diagnostic_settings.tftest.hcl
│   ├── defaults.tftest.hcl      # Default value validation
│   ├── naming.tftest.hcl        # Naming convention tests
│   ├── outputs.tftest.hcl       # Output validation
│   └── validation.tftest.hcl    # Input variable validation
├── go.mod                       # Go module definition and dependencies
├── go.sum                       # Dependency checksums
├── Makefile                     # Helper scripts for running tests
├── kubernetes_cluster_test.go   # Main tests for basic scenarios (e.g., basic, complete)
├── integration_test.go          # More complex integration and lifecycle tests
├── performance_test.go          # Performance tests and benchmarks
├── test_helpers.go              # Helper functions, validation, and Azure SDK clients
├── test_config.yaml             # Test suite configuration for CI/CD
├── test_env.sh                  # Script for setting local environment variables
├── run_tests_parallel.sh        # Script for running tests in parallel with reporting
├── run_tests_sequential.sh      # Script for running tests sequentially with reporting
└── test_outputs/                # Directory for test results (ignored by Git)
    └── .gitkeep
```

> Note: Legacy modules may still use `simple`/`security` fixture names. New modules should use `basic`/`secure`.

## Test File Naming Conventions

### Native Terraform Tests (Unit Tests)

Located in `tests/unit/`, these files use the `terraform test` command to validate module logic without deploying infrastructure.

| File | Purpose |
|------|---------|
| `defaults.tftest.hcl` | Verifies that secure and functional defaults are applied correctly. |
| `naming.tftest.hcl` | Tests naming conventions, prefixes, suffixes, and constraints. |
| `outputs.tftest.hcl` | Validates the structure, format, and values of module outputs. |
| `validation.tftest.hcl`| Tests all input variable validation rules with negative test cases. |
| `containers.tftest.hcl`| (Or similar) Tests conditional creation of sub-resources. |

**Pattern**: `{feature_or_logic_area}.tftest.hcl`

### Terratest Go Files (Integration Tests)

Located in the root of `tests/`, these files use the Go testing framework and Terratest to deploy and validate real Azure infrastructure.

| File | Purpose |
|------|---------|
| `{module_name}_test.go` | **Main Test File**: Contains the primary test functions for basic and common scenarios (e.g., `basic`, `complete`, `secure`). |
| `integration_test.go` | **Advanced Tests**: For complex scenarios, including resource lifecycle (updates, idempotency), disaster recovery, and compliance checks. |
| `performance_test.go` | **Performance Tests**: Contains benchmarks (`Benchmark...`) and tests that validate deployment time SLAs. |
| `test_helpers.go` | **Utilities**: A crucial file containing shared helper functions, Azure SDK clients, and custom validation logic to keep test files clean and DRY. |

**Pattern**: `{module_name}_test.go` for the main file, with other files named for their specific purpose.

## Test Function Naming Conventions

### Native Terraform Tests

Test blocks within `.tftest.hcl` files should be descriptive.

```hcl
# Pattern: run "{action}_{feature}_{scenario}" { ... }
run "verify_secure_defaults_are_applied" { ... }
run "test_name_with_suffix" { ... }

# Negative tests should clearly state the invalid case
run "invalid_name_too_short" {
  expect_failures = [var.name]
}
```

### Terratest Go Functions

Go test functions must follow standard Go conventions and be descriptive.

```go
// Pattern: Test{Module}{Scenario}
func TestBasicKubernetesCluster(t *testing.T) { ... }
func TestCompleteKubernetesCluster(t *testing.T) { ... }
func TestSecureKubernetesCluster(t *testing.T) { ... }

// For integration_test.go
func TestKubernetesClusterLifecycle(t *testing.T) { ... }
func TestKubernetesClusterCompliance(t *testing.T) { ... }

// For performance_test.go
func BenchmarkKubernetesClusterCreation(b *testing.B) { ... }
func TestKubernetesClusterCreationTime(t *testing.T) { ... }
```

## Test Categorization

Tests are categorized by type and scope to allow for flexible execution in different environments (local vs. CI/CD).

### By Type

| Type | Purpose | Location | Execution | Cost |
|---|---|---|---|---|
| **Unit** | Validate module logic without deploying resources. | `tests/unit/` | `terraform test` | Free |
| **Integration** | Validate real Azure resource deployment and configuration. | `tests/*_test.go` | `go test` | Minimal Azure cost |
| **Performance**| Benchmark resource creation time and performance SLAs. | `tests/performance_test.go` | `go test -bench` | Moderate Azure cost |

### By Scope (using Go's `testing.Short()` flag)

- **Short Tests**: Run on every pull request. They provide a quick feedback loop. These are standard `Test...` functions.
- **Long-Running Tests**: Skipped during pull request builds to save time. These include advanced integration and performance tests. They are marked with a check at the beginning of the function.

```go
// In integration_test.go or performance_test.go
func TestKubernetesClusterLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	// ... rest of the test
}
```

## Test Execution with `test-structure`

To ensure robustness and proper cleanup, all integration tests must use the `test-structure` library to define distinct stages. This guarantees that cleanup code (`terraform destroy`) always runs, even if validation fails.

```go
func TestBasicKubernetesCluster(t *testing.T) {
    t.Parallel()

    // 1. Setup: Copy the fixture to a temp folder
    testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_kubernetes_cluster/tests/fixtures/basic")

    // 2. Defer Cleanup: Ensure destroy is always called
    defer test_structure.RunTestStage(t, "cleanup", func() {
        terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
        terraform.Destroy(t, terraformOptions)
    })

    // 3. Deploy: Run terraform init and apply
    test_structure.RunTestStage(t, "deploy", func() {
        terraformOptions := getTerraformOptions(t, testFolder)
        // Save options for other stages
        test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
        terraform.InitAndApply(t, terraformOptions)
    })

    // 4. Validate: Run assertions against the deployed infrastructure
    test_structure.RunTestStage(t, "validate", func() {
        terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
        // ... validation logic ...
    })
}
```
