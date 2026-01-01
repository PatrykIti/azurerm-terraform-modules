# Fixtures and Test Execution

This guide covers the standards for creating test configurations (`fixtures`) and the tools used to execute the tests, including `Makefile` and supplementary shell scripts.

## Test Fixtures

Test fixtures are small, self-contained Terraform configurations located in the `tests/fixtures` directory. Each subdirectory represents a specific scenario to be tested.

### Fixture Naming Conventions and Purpose

To ensure consistency across all modules, the following fixture names and purposes should be used where applicable:

| Fixture Name | Purpose |
|---|---|
| `basic` | A minimal, valid configuration to test basic resource creation and default values. |
| `complete` | A complex configuration that enables and tests the majority of the module's features. |
| `secure` | A configuration focused on security-hardened settings (e.g., private cluster, policy, restricted access). |
| `network` | Scenarios for advanced networking (e.g., VNet integration, custom DNS, network policy). |
| `negative/` | A parent directory for configurations that are expected to fail Terraform validation or apply, used for negative testing. |
| `<feature-specific>/` | Optional scenarios for module-specific features (e.g., diagnostics, extra pools, identity). |

> Note: Legacy modules may still use `simple`/`security` fixture names. New modules should use `basic`/`secure`.

### Fixture Internal Structure

Each fixture directory must contain the following files:

-   `main.tf`: The main Terraform configuration for the test scenario.
-   `variables.tf`: Defines the input variables for the fixture.
-   `outputs.tf`: Exposes the key attributes of the created resources for validation in Go tests.

### Best Practices for Writing Fixtures

1.  **Use a Local Module Source**: Fixtures must always test the local version of the module using a relative path to ensure that changes are tested before they are merged.
    ```hcl
    # in fixtures/basic/main.tf
    module "kubernetes_cluster" {
      # This path points to the module's root directory
      source = "../../../" 

      name                = "aks-dpc-bas-${var.random_suffix}"
      resource_group_name = azurerm_resource_group.test.name
      # ... other variables
    }
    ```

2.  **Ensure Unique and Descriptive Resource Names**: To enable parallel testing and easy identification in Azure or Azure DevOps, all resources within a fixture must have unique names. AzureRM fixtures follow the established naming patterns from the `azurerm_kubernetes_cluster` module, which sets the standard for this repository.

    ### Resource Naming Pattern for Test Fixtures
    
    The standard pattern for test fixtures differs from examples and uses project identifiers:
    -   **Resource Groups**: `rg-{project}-{scenario}-${var.random_suffix}`
    -   **Main Module Resource**: `{prefix}{project}{scenario}${var.random_suffix}`
    -   **Other Resources**: `{type}-{project}-{scenario}-${var.random_suffix}`

    ### Resource Prefix Standards
    
    | Resource Type | Prefix | Test Example |
    |--------------|--------|--------------|
| Resource Group | `rg-` | `rg-dpc-bas-${var.random_suffix}` |
| Virtual Network | `vnet-` | `vnet-dpc-cmp-${var.random_suffix}` |
| Subnet | `snet-` | `snet-dpc-cmp-${var.random_suffix}` |
| Network Security Group | `nsg-` | `nsg-dpc-sec-${var.random_suffix}` |
| Log Analytics Workspace | `law-` | `law-dpc-cmp-${var.random_suffix}` |
| User Assigned Identity | `uai-` | `uai-dpc-cmp-${var.random_suffix}` |
| AKS Cluster | `aks-` | `aks-dpc-bas-${var.random_suffix}` |

    ### Standard Abbreviations
    
    - `{project}` is a short identifier for the overall project (e.g., `dpc`).
    - `{scenario}` is a short identifier for the fixture:
      - `bas` - basic
      - `smp` - legacy simple
      - `cmp` - complete
      - `sec` - security/secure
      - `net` - network
      - `neg` - negative

    **Example (`fixtures/basic/main.tf`):**
    ```hcl
    # variables.tf
    variable "random_suffix" {
      type        = string
      description = "A random suffix passed from the test to ensure unique resource names."
    }

    # main.tf
    resource "azurerm_resource_group" "test" {
      # e.g., rg-dpc-bas-a1b2c3
      name     = "rg-dpc-bas-${var.random_suffix}"
      location = var.location
    }

    module "kubernetes_cluster" {
      source = "../../../"

      # e.g., aks-dpc-bas-a1b2c3
      name                = "aks-dpc-bas-${var.random_suffix}"
      resource_group_name = azurerm_resource_group.test.name
      # ... other variables
    }
    ```

    **Key Differences from Examples:**
    - Test fixtures ALWAYS use `var.random_suffix` for uniqueness (never `random_string` resource)
    - Test fixtures use abbreviated scenario names (e.g., `bas` vs `basic`; legacy modules may use `smp` vs `simple`)
    - Test fixtures include project identifier (`dpc`) in resource names
    - All test resources must support parallel execution

    ### Azure DevOps Fixture Naming

    Azure DevOps fixtures are project-scoped and do not create Azure resource groups. Use a unique prefix derived from the Go test to avoid collisions.

    **Example (`modules/azuredevops_repository/tests/fixtures/basic/main.tf`):**
    ```hcl
    # variables.tf
    variable "repo_name_prefix" {
      type        = string
      description = "Prefix used for repository names in tests."
    }

    # main.tf
    module "azuredevops_repository" {
      source = "../../../"

      project_id = var.project_id
      name       = "${var.repo_name_prefix}-basic"
    }
    ```
    In Go tests, `project_id` is typically injected from `AZDO_PROJECT_ID`.

3.  **Define Clear Outputs for Validation**: Each fixture must expose the key attributes of the created resources as outputs. The Go tests will read these outputs to get the names and IDs needed for validation with the Azure SDK.
    ```hcl
    # in fixtures/basic/outputs.tf
    output "kubernetes_cluster_id" {
      description = "The ID of the created Kubernetes Cluster."
      value       = module.kubernetes_cluster.id
    }

    output "kubernetes_cluster_name" {
      description = "The name of the created Kubernetes Cluster."
      value       = module.kubernetes_cluster.name
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
| `make test-basic` | Runs only the `TestBasicKubernetesCluster` test. |
| `make test-secure` | Runs only the security-focused test (e.g., `TestSecureKubernetesCluster`). |
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

# Run only the secure test
make test-single TEST_NAME=TestSecureKubernetesCluster

# Check for linting errors
make lint
```

Note: target names are consistent, but the underlying Go test names vary per module
(for example `TestBasicAzuredevopsRepository` in Azure DevOps modules).

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
