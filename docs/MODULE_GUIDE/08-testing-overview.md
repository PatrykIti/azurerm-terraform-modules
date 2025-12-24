# 8. Testing Overview

Comprehensive testing is mandatory for every module to ensure it is reliable, secure, and production-ready. Our testing strategy employs a multi-layered approach, combining static analysis, native Terraform tests, and integration tests with Terratest.

While this guide provides a brief overview, the **[Terraform Testing Guide](../TESTING_GUIDE/README.md)** contains the full, detailed explanation of our testing philosophy, structure, and implementation. **All developers MUST read the full testing guide.**

## Testing Layers

### 1. Static Analysis & Validation (`make validate`, `make security`)
- **Purpose**: Catch errors without deploying resources.
- **Tools**:
  - `terraform validate`: Checks syntax and configuration.
  - `terraform fmt -check`: Enforces code style.
  - `tfsec` / `checkov`: Scans for security misconfigurations.
- **Execution**: This is the fastest feedback loop and should be run frequently during development.

### 2. Unit Tests (`terraform test`)
- **Purpose**: Test module logic in isolation using mocks.
- **Framework**: Native Terraform test framework (`.tftest.hcl` files).
- **Location**: `tests/unit/`
- **Key Areas**:
  - Variable validation rules.
  - Default values.
  - Conditional logic (e.g., enabling/disabling features).
  - Output correctness.

### 3. Integration Tests (`make test`)
- **Purpose**: Deploy real resources to Azure to verify functionality in a live environment.
- **Framework**: [Terratest](https://terratest.gruntwork.io/) (Go-based).
- **Location**: `tests/*.go`
- **Key Areas**:
  - **Basic**: A minimal deployment works as expected.
  - **Complete**: All features can be enabled and deployed successfully.
  - **Secure**: Security-hardened configurations are valid.
  - **Lifecycle**: The module can be updated and shows idempotent behavior (no changes on a second `apply`).

## Test Structure within a Module

The `tests/` directory is structured to support this multi-layered approach:

```
tests/
├─── fixtures/                # Terraform code for Terratest scenarios
│    ├─── basic/
│    ├─── complete/
│    ├─── secure/
│    ├─── network/
│    └─── negative/
├─── unit/                    # Native Terraform tests
│    ├─── defaults.tftest.hcl
│    ├─── naming.tftest.hcl
│    ├─── validation.tftest.hcl
│    └─── outputs.tftest.hcl
├─── go.mod                   # Go dependencies for Terratest
├─── go.sum
├─── <module>_test.go          # Module-specific Terratest
├─── integration_test.go
├─── performance_test.go
├─── test_helpers.go
├─── test_config.yaml
├─── test_env.sh
├─── run_tests_parallel.sh
├─── run_tests_sequential.sh
├─── test_outputs/
└─── Makefile                  # Helper to run tests
```

Note: dynamic/random naming is reserved for Go-based E2E tests in `tests/` and should not be used in examples.

## Next Steps

For detailed instructions on how to write and run tests, including setting up your environment, writing Terratest code, and using test fixtures, please refer to the **[Terraform Testing Guide](../TESTING_GUIDE/README.md)**.
