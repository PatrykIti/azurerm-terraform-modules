# Azure DevOps User Entitlement Module Tests

This directory contains automated tests for the Azure DevOps User Entitlement Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure DevOps Organization**: Access with a Personal Access Token (PAT)

## Environment Variables

Set the following environment variables before running tests:

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/your-org"
export AZDO_PERSONAL_ACCESS_TOKEN="your-pat"
export AZDO_USER_PRINCIPAL_NAME="user@example.com"
export AZDO_USER_ORIGIN_ID="00000000-0000-0000-0000-000000000000"
export AZDO_USER_ORIGIN="aad"
```

You can override user selectors per fixture by suffixing the variable with the fixture name (e.g. `_BASIC`, `_SECURE`, `_COMPLETE`, `_NEGATIVE`). The tests fall back to the generic variables if a fixture-specific one is not set.

```bash
export AZDO_USER_PRINCIPAL_NAME_BASIC="basic.user@example.com"
export AZDO_USER_PRINCIPAL_NAME_SECURE="secure.user@example.com"
export AZDO_USER_ORIGIN_ID_COMPLETE="11111111-1111-1111-1111-111111111111"
export AZDO_USER_ORIGIN_COMPLETE="aad"
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

### Run Integration Tests Only

```bash
make test-integration
```

## Test Structure

### Test Files

- `azuredevops_user_entitlement_test.go` - Basic, complete, secure, and validation tests
- `integration_test.go` - Full apply test using the complete fixture
- `performance_test.go` - Benchmarks are disabled by default

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Complete feature demonstration
- `fixtures/secure/` - Security-focused configuration
- `fixtures/negative/` - Negative test cases

## Debugging Tests

### Verbose Output

```bash
go test -v -run TestBasicAzuredevopsUserEntitlement
```

### Keep Resources After Test Failure

Set the `SKIP_TEARDOWN` environment variable:

```bash
export SKIP_TEARDOWN=true
go test -v -run TestBasicAzuredevopsUserEntitlement
```

## Continuous Integration

Tests are automatically run in CI/CD pipelines:

- **Pull Requests**: Short tests only
- **Main Branch**: All tests including integration

## Contributing

When adding new tests:

1. Follow the existing test structure and naming conventions
2. Add appropriate fixtures in the `fixtures/` directory
3. Keep tests idempotent and clean up resources
