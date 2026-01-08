# Azure DevOps Security Role Assignment Module Tests

This directory contains automated tests for the Azure DevOps Security Role Assignment module using [Terratest](https://terratest.gruntwork.io/) and native `terraform test`.

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure DevOps Organization**: Access with a Personal Access Token (PAT)
4. **Azure DevOps Project**: Existing project ID for `scope = "project"`
5. **Identity IDs**: Distinct identities for basic/complete/secure scenarios

## Environment Variables

Set the following environment variables before running tests:

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/your-org"
export AZDO_PERSONAL_ACCESS_TOKEN="your-pat"
export AZDO_PROJECT_ID="your-project-id"
export AZDO_SECURITYROLE_ASSIGNMENT_IDENTITY_ID_BASIC="your-identity-id-basic"
export AZDO_SECURITYROLE_ASSIGNMENT_IDENTITY_ID_COMPLETE="your-identity-id-complete"
export AZDO_SECURITYROLE_ASSIGNMENT_IDENTITY_ID_SECURE="your-identity-id-secure"
```

## Running Tests

### Install Dependencies

```bash
go mod download
```

### Run All Go Tests

```bash
make test
```

### Run Terraform Unit Tests

```bash
terraform test -test-directory=./unit
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

- `azuredevops_securityrole_assignment_test.go` - Basic, complete, secure, and validation tests
- `integration_test.go` - Full apply test using the complete fixture
- `performance_test.go` - Benchmarks are disabled by default

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic assignment
- `fixtures/complete/` - Assignment with explicit role selection
- `fixtures/secure/` - Least-privilege assignment
- `fixtures/negative/` - Negative test cases

### Unit Tests

- `unit/` - Native Terraform tests (`.tftest.hcl`)

## Debugging Tests

### Verbose Output

```bash
go test -v -run TestBasicAzuredevopsSecurityroleAssignment
```

### Keep Resources After Test Failure

Set the `SKIP_TEARDOWN` environment variable:

```bash
export SKIP_TEARDOWN=true
go test -v -run TestBasicAzuredevopsSecurityroleAssignment
```

## Test Output Logs

Each `make test*` target stores a timestamped log under `test_outputs/`:

```
test_outputs/<target>_<timestamp>.log
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
