# Subnet Module Tests

This directory contains automated tests for the Subnet Terraform module using native Terraform tests and [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure CLI**: Authenticated with appropriate permissions
4. **Azure Service Principal**: Contributor access to the test subscription

## Environment Variables

Set the following environment variables before running Terratest:

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_LOCATION="West Europe" # Optional, defaults to West Europe
```

## Running Tests

### Native Terraform Unit Tests

Run from the module root:

```bash
terraform test -test-directory=tests/unit
```

### Terratest (Go)

```bash
cd tests
make test
```

Useful targets:

```bash
make test-basic
make test-complete
make test-secure
make test-network
make test-private-endpoint
make test-validation
make test-integration
make test-single TEST_NAME=TestSubnetSecurity
```

## Test Structure

### Test Files

- `subnet_test.go` - Core module tests
- `integration_test.go` - Cross-feature integration tests
- `performance_test.go` - Performance and benchmark tests
- `test_helpers.go` - Shared helpers and utilities
- `test_config.yaml` - Test configuration

### Fixtures

The `fixtures/` directory contains Terraform configurations for test scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Feature-complete configuration
- `fixtures/secure/` - Security-focused configuration
- `fixtures/network/` - Network integration tests
- `fixtures/private_endpoint/` - Private endpoint scenario
- `fixtures/negative/` - Negative validation cases

## Test Output Logs

For structured logs, use the helper scripts:

```bash
./run_tests_parallel.sh
./run_tests_sequential.sh
```

Logs and summaries are written under `test_outputs/`.

## Cleanup

```bash
make clean
```

## CI Notes

The `make test-junit` target generates a JUnit XML report (`test-results.xml`) for CI usage.
