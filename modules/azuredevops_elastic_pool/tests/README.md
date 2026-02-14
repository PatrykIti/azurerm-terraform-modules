# Azure DevOps Elastic Pool Module Tests

This directory contains automated tests for the Azure DevOps Elastic Pool Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure DevOps Organization**: Access with a Personal Access Token (PAT)

## Environment Variables

Set the following environment variables before running tests:

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/your-org"
export AZDO_PERSONAL_ACCESS_TOKEN="your-pat"
export AZDO_TEST_SERVICE_ENDPOINT_ID="00000000-0000-0000-0000-000000000001"
export AZDO_TEST_SERVICE_ENDPOINT_SCOPE="00000000-0000-0000-0000-000000000000"
export AZDO_TEST_AZURE_RESOURCE_ID="/subscriptions/.../resourceGroups/.../providers/Microsoft.Compute/virtualMachineScaleSets/..."
```

## Running Tests

### Install Dependencies

```bash
go mod download
```

### Run All Tests

```bash
make test
```

### Run Basic Tests Only

```bash
make test-basic
```

### Run Complete Tests Only

```bash
make test-complete
```

### Run Secure Tests Only

```bash
make test-secure
```

### Run Validation Pattern

```bash
make test-validation
```

### Run Integration Tests Only

```bash
make test-integration
```

## Test Structure

### Test Files

- `azuredevops_elastic_pool_test.go` - Basic, complete, and secure tests
- `integration_test.go` - Full apply test using the complete fixture
- `performance_test.go` - Benchmarks are disabled by default

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Full optional configuration
- `fixtures/secure/` - Security-focused configuration

## Troubleshooting

1. **Authentication errors**: Verify `AZDO_ORG_SERVICE_URL` and `AZDO_PERSONAL_ACCESS_TOKEN`
2. **Missing endpoint context**: Provide all `AZDO_TEST_*` values used by fixtures
3. **Timeouts**: Increase `TIMEOUT` in `tests/Makefile` for slower organizations
