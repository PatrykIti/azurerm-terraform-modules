# Fixtures and Test Execution

This guide covers the standards for creating test configurations (`fixtures`) and the tools used to execute the tests, including `Makefile` and supplementary shell scripts.

## Test Fixtures

Test fixtures are small, self-contained Terraform configurations located in the `tests/fixtures` directory. Each subdirectory represents a specific scenario to be tested.

### Fixture Organization

A well-organized `fixtures` directory is crucial for covering a wide range of scenarios.

**Standard Structure:**
```
tests/
└── fixtures/
    ├── simple/           # Minimal, valid configuration to test basic resource creation.
    ├── complete/         # A complex configuration that enables most of the module's features.
    ├── security/         # A configuration focused on security-hardened settings.
    ├── network/          # Scenarios for advanced networking (e.g., VNet integration, IP rules).
    ├── private_endpoint/ # A specific scenario for private endpoint integration.
    └── negative/         # Subdirectories for configurations that are expected to fail validation.
        ├── invalid_name_short/
        └── invalid_replication_type/
```

### Best Practices for Fixtures

1.  **Use a Local Module Source**: Fixtures must always test the local version of the module using a relative path.
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

2.  **Ensure Unique Resource Names**: To enable parallel testing, all resources must have unique names. This is achieved by accepting a `random_suffix` variable from the Go test code.
    ```hcl
    # in fixtures/simple/variables.tf
    variable "random_suffix" {
      type        = string
      description = "A random suffix passed from the test to ensure unique resource names."
    }

    # in fixtures/simple/main.tf
    resource "azurerm_resource_group" "test" {
      name     = "rg-test-${var.random_suffix}"
      location = var.location
    }
    ```

3.  **Define Outputs for Validation**: Each fixture must expose the key attributes of the created resources as outputs. The Go tests will read these outputs to get the names and IDs needed for validation with the Azure SDK.
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

### Advanced Execution Scripts

For more complex orchestration, such as generating custom reports, the following scripts are provided:

-   `run_tests_parallel.sh`: Executes all test functions in parallel as separate processes and generates a detailed JSON report for each. It creates a final `summary.json` with the results of the entire run.
-   `run_tests_sequential.sh`: Executes tests one by one. This is useful for debugging, as it makes logs easier to follow.

### Test Configuration (`test_config.yaml`)

This file provides a way to configure test execution behavior without modifying code or scripts. It can be used by CI/CD pipelines to define different test suites.

**Example Structure:**
```yaml
# test_config.yaml
test_suites:
  - name: "Pull Request Quick Checks"
    tests:
      - TestBasicStorageAccount
      - TestStorageAccountValidationRules
    parallel: true
    timeout: 15m
    
  - name: "Nightly Full Run"
    tests:
      - TestCompleteStorageAccount
      - TestStorageAccountSecurity
      - TestStorageAccountLifecycle
    parallel: true
    timeout: 45m

coverage:
  enabled: true
  threshold: 80

reporting:
  format: junit
  output_dir: test-results/
```