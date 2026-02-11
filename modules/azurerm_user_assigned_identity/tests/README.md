# User Assigned Identity Module Tests

This directory contains automated tests for the User Assigned Identity Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure CLI**: Authenticated with appropriate permissions
4. **Azure Service Principal**: With Contributor access to the test subscription

## Environment Variables

Set the following environment variables before running tests:

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_LOCATION="West Europe"  # Optional, defaults to West Europe
```

## Running Tests

### Install Dependencies

```bash
go mod download
```

### Run All Tests

```bash
make test-all
```

### Run Short Tests Only

```bash
make test-short
```

### Run Integration Tests Only

```bash
make test-integration
```

### Run Specific Test

```bash
go test -v -run TestBasicUserAssignedIdentity -timeout 30m
```

## Test Structure

### Test Files

- `user_assigned_identity_test.go` - Main module functionality tests
- `integration_test.go` - Full integration validation
- `performance_test.go` - Performance benchmarks
- `test_helpers.go` - Common test utilities and helpers
- `test_config.yaml` - Test configuration and scenarios

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - UAI with federated identity credentials
- `fixtures/secure/` - UAI with RBAC example
- `fixtures/federated-identity-credentials/` - Dedicated FIC fixture
- `fixtures/negative/` - Negative test cases

## Debugging Tests

### Verbose Output

```bash
go test -v -run TestBasicUserAssignedIdentity
```

### Keep Resources After Test Failure

Set the `SKIP_TEARDOWN` environment variable:

```bash
export SKIP_TEARDOWN=true
go test -v -run TestBasicUserAssignedIdentity
```

### Debug Terraform

Enable Terraform debug logging:

```bash
export TF_LOG=DEBUG
go test -v -run TestBasicUserAssignedIdentity
```
