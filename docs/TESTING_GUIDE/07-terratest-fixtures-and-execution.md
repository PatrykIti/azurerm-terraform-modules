# Fixtures and Test Execution

This guide covers the standards for creating test configurations (`fixtures`) and the tools used to execute the tests, including `Makefile` and supplementary shell scripts.

## Test Fixtures

Test fixtures are small, self-contained Terraform configurations located in the `tests/fixtures` directory. Each subdirectory represents a specific scenario to be tested.

### Fixture Naming Conventions and Purpose

To ensure consistency across all modules, the following fixture names and purposes should be used where applicable:

| Fixture Name | Purpose |
|---|---|
| `simple` | A minimal, valid configuration to test basic resource creation and default values. |
| `complete` | A complex configuration that enables and tests the majority of the module's features. |
| `security` | A configuration focused on security-hardened settings (e.g., disabled public access, private endpoints, CMK). |
| `network` | Scenarios for advanced networking (e.g., VNet integration, multiple IP rules, service endpoints). |
| `private_endpoint`| A specific scenario dedicated to validating private endpoint integration. |
| `data_lake_gen2` | (Or similar) For features specific to a certain SKU or configuration, like Data Lake Gen2. |
| `identity_access` | Tests for managed identity (System and User Assigned) and Customer-Managed Key (CMK) encryption. |
| `negative/` | A parent directory for configurations that are expected to fail Terraform validation or apply, used for negative testing. |

### Fixture Internal Structure

Each fixture directory must contain the following files:

-   `main.tf`: The main Terraform configuration for the test scenario.
-   `variables.tf`: Defines the input variables for the fixture.
-   `outputs.tf`: Exposes the key attributes of the created resources for validation in Go tests.

### Best Practices for Writing Fixtures

1.  **Use a Local Module Source**: Fixtures must always test the local version of the module using a relative path to ensure that changes are tested before they are merged.
    ```hcl
    # in fixtures/simple/main.tf
    module "storage_account" {
      # This path points to the module's root directory
      source = "../../../" 

      name                = "stsimple${var.random_suffix}"
      resource_group_name = azurerm_resource_group.test.name
      # ... other variables
    }
    ```

2.  **Ensure Unique and Descriptive Resource Names**: To enable parallel testing and easy identification in Azure, all resources within a fixture must have unique names. The standard pattern is:
    -   **Resource Groups**: `rg-{project}-{scenario}-${var.random_suffix}`
    -   **Main Module Resource**: `{prefix}{scenario}${var.random_suffix}`
    -   **Other Resources**: `{type}-{project}-{scenario}-${var.random_suffix}`

    **Example (`fixtures/simple/main.tf`):**
    ```hcl
    # variables.tf
    variable "random_suffix" {
      type        = string
      description = "A random suffix passed from the test to ensure unique resource names."
    }

    # main.tf
    resource "azurerm_resource_group" "test" {
      # e.g., rg-dpc-smp-a1b2c3
      name     = "rg-dpc-smp-${var.random_suffix}"
      location = var.location
    }

    module "storage_account" {
      source = "../../../"

      # e.g., dpcsmpa1b2c3
      name                     = "dpcsmp${var.random_suffix}"
      resource_group_name      = azurerm_resource_group.test.name
      # ... other variables
    }
    ```
    - `{project}` is a short identifier for the overall project (e.g., `dpc`).
    - `{scenario}` is a short identifier for the fixture (e.g., `smp` for simple, `cmp` for complete, `sec` for security).
    - `{prefix}` is a short, lowercase identifier for the resource type (e.g., `st` for storage account).
    - `var.random_suffix` is a unique string passed from the Go test.

3.  **Define Clear Outputs for Validation**: Each fixture must expose the key attributes of the created resources as outputs. The Go tests will read these outputs to get the names and IDs needed for validation with the Azure SDK.
    ```hcl
    # in fixtures/simple/outputs.tf
    output "storage_account_id" {
      description = "The ID of the created storage account."
      value       = module.storage_account.id
    }

    output "storage_account_name" {
      description = "The name of the created storage account."
      value       = module.storage_account.name
    }
    ```

## Test Execution

A `Makefile` in the `tests` directory serves as the standardized interface for running all test-related commands.

### Using the `Makefile`

The `Makefile` provides convenient targets for common operations, ensuring that tests are run the same way by every developer and in the CI/CD pipeline.

**Key `Makefile` Targets:**

| Target | Description |
|---|---|
| `make test` | Runs all Go tests in parallel. The default command for a full test run. |
| `make test-single TEST_NAME=<TestFunctionName>` | Runs a single, specific test function. Useful for debugging. |
| `make test-basic` | Runs only the `TestBasicStorageAccount` test. |
| `make test-security` | Runs only the `TestStorageAccountSecurity` test. |
| `make benchmark` | Runs all performance benchmarks. |
| `make test-coverage` | Runs tests and generates an HTML code coverage report (`coverage.html`). |
| `make test-junit` | Runs tests and generates a JUnit XML report (`test-results.xml`) for CI/CD integration. |
| `make lint` | Runs the `golangci-lint` linter to check for code style issues. |
| `make fmt` | Formats all Go code using `gofmt`. |
| `make clean` | Deletes all test artifacts, including temporary folders and state files. |
| `make ci` | A comprehensive target that simulates the CI/CD pipeline by running `fmt`, `lint`, `test-coverage`, and `test-junit`. |

**Example Usage:**
```bash
# Run all tests with a 45-minute timeout
make test TIMEOUT=45m

# Run only the private endpoint test
make test-single TEST_NAME=TestStorageAccountPrivateEndpoint

# Check for linting errors
make lint
```

## Advanced Test Execution Scripts (Per-Module)

For more complex test orchestration, such as generating detailed reports or running a predefined list of tests for a specific module, each module's `tests` directory can contain reusable shell scripts.

### `run_tests_parallel.sh`
- **Purpose**: Executes all `Test...` functions in the Go test files in parallel. It captures the output of each test in a separate log file and generates a JSON summary report.
- **Location**: Should be present in the `tests/` directory of a module that requires advanced test orchestration.
- **Use Case**: Ideal for local development and CI/CD runs where you need a structured report of all test outcomes, even if some fail.

### `run_tests_sequential.sh`
- **Purpose**: Executes all `Test...` functions sequentially. This is slower but can be easier for debugging as the output is not interleaved.
- **Location**: Should be present in the `tests/` directory of a module.
- **Use Case**: Useful for local debugging of complex test failures.

By using these standardized scripts and `Makefile` targets, we ensure a consistent and powerful testing workflow across all modules.
