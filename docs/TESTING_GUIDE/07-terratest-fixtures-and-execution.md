# Fixtures and Test Execution

Effective management of test configurations (`fixtures`) and automated test execution are key to an efficient CI/CD process. This section describes the standards for organizing `fixtures` and using `Makefile` and `bash` scripts to orchestrate tests.

## Fixture Organization

The `tests/fixtures` directory contains subdirectories, each representing a separate, isolated test scenario in the form of a complete Terraform configuration.

### `fixtures` Directory Structure

```
tests/
└── fixtures/
    ├── simple/           # A minimal, working configuration of the module.
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── complete/         # A configuration testing all or most of the module's features.
    ├── security/         # A configuration with the most restrictive security settings.
    ├── network/          # A scenario testing advanced network rules.
    ├── private_endpoint/ # A scenario using a Private Endpoint.
    └── negative/         # A collection of intentionally incorrect configurations.
        ├── invalid_name_short/
        └── invalid_replication_type/
```

### Best Practices for Fixtures

1.  **Local Module Source**: Each `fixture` must reference the module being tested using a relative path to test local changes.
    ```hcl
    # fixtures/simple/main.tf
    module "storage_account" {
      source = "../../../" # Reference to the module's root directory

      # ... variables
    }
    ```

2.  **Unique Resource Names**: Use the `random_suffix` variable, passed from the Go test, to create unique resource names.
    ```hcl
    # fixtures/simple/variables.tf
    variable "random_suffix" {
      type        = string
      description = "A random suffix to ensure unique resource names."
    }

    # fixtures/simple/main.tf
    resource "azurerm_resource_group" "test" {
      name     = "rg-test-${var.random_suffix}"
      location = var.location
    }
    ```

3.  **Minimalism**: A `fixture` should only contain the configuration necessary to test a given scenario. Avoid adding unrelated resources.

4.  **Outputs**: Each `fixture` must define an `outputs.tf` file that exposes key attributes of the deployed resources. These values are then read and validated in the Go tests.
    ```hcl
    # fixtures/simple/outputs.tf
    output "storage_account_id" {
      value = module.storage_account.id
    }

    output "storage_account_name" {
      value = module.storage_account.name
    }
    ```

## Running Tests

We use `Makefile` as the main interface for running tests, which simplifies and standardizes the process both locally and in CI/CD.

### `Makefile`

The `Makefile` defines a set of commands (targets) to manage the test lifecycle.

**Key Targets (`modules/azurerm_storage_account/tests/Makefile`):**
```makefile
# Configuration variables
TIMEOUT ?= 30m
PARALLEL ?= 8

# Check environment variables
check-env:
	@test -n "$(AZURE_SUBSCRIPTION_ID)" || (echo "AZURE_SUBSCRIPTION_ID is not set" && exit 1)
    # ... (other variables)

# Install dependencies
deps:
	go mod download
	go mod tidy

# Run all tests
test: check-env deps
	go test -v -timeout $(TIMEOUT) -parallel $(PARALLEL) ./...

# Run a specific test
test-single: check-env deps
	go test -v -timeout $(TIMEOUT) -run $(TEST_NAME) ./...

# Run tests with a coverage report
test-coverage: check-env deps
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

# Generate a JUnit report for CI/CD
test-junit: check-env deps
	go install github.com/jstemmer/go-junit-report/v2@latest
	go test -v ./... 2>&1 | go-junit-report -set-exit-code > test-results.xml

# Clean up artifacts
clean:
	rm -f coverage.out test-results.xml
	find . -name "*.tfstate*" -type f -delete
```

**Usage:**
```bash
# Run all tests
make test

# Run only basic tests
make test-basic

# Run a specific test
make test-single TEST_NAME=TestStorageAccountSecurity

# Generate a code coverage report
make test-coverage
```

### Execution Scripts (`run_tests_*.sh`)

For more advanced orchestration, especially for generating detailed reports, we use `bash` scripts.

#### `run_tests_parallel.sh`

-   **Purpose**: Runs all defined tests in parallel, each in a separate process.
-   **Key Features**:
    -   Runs tests in the background (`&`).
    -   Collects process PIDs and waits for them to complete (`wait`).
    -   Generates a separate `.log` and `.json` file with metadata (status, duration, error) for each test.
    -   Finally, creates a `summary.json` file with the results of all tests.
    -   **Always exits with code 0** so that the full report can be analyzed in CI/CD, even if some tests failed.

#### `run_tests_sequential.sh`

-   **Purpose**: Runs tests one after another. Ideal for debugging.
-   **Key Features**:
    -   Runs tests in a `for` loop.
    -   Displays live logs in the console (`tee`).
    -   Similar to the parallel version, generates individual JSON reports and a summary.

### Test Configuration (`test_config.yaml`)

This file allows you to define test suites and other parameters that can be used by execution scripts or CI/CD tools to dynamically build test matrices.

```yaml
# test_config.yaml
test_suites:
  - name: "Basic Tests"
    tests:
      - TestBasicStorageAccount
    parallel: true
    timeout: 15m
    
  - name: "Complete Feature Tests"
    tests:
      - TestCompleteStorageAccount
      - TestStorageAccountSecurity
    parallel: true
    timeout: 30m

coverage:
  enabled: true
  threshold: 80

reporting:
  format: junit
  output_dir: test-results/
```
This file makes it easy to manage which tests belong to which category (e.g., "quick", "full") without modifying the scripts.
