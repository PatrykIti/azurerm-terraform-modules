# Kubernetes Namespace Module Tests

This directory contains automated tests for the Kubernetes Namespace Terraform module using [Terratest](https://terratest.gruntwork.io/).

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
export ARM_LOCATION="northeurope"  # Optional, defaults to northeurope
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

### Run Short Tests Only

```bash
make test-quick
```

### Run Integration Tests Only

```bash
make test-integration
```

### Run Specific Test

```bash
go test -v -run TestBasicKubernetesNamespace -timeout 30m
```

## Test Structure

### Test Files

- `kubernetes_namespace_test.go` - Main module functionality tests
- `integration_test.go` - Lifecycle/idempotency test
- `performance_test.go` - Performance and timing tests
- `test_helpers.go` - Common test utilities and helpers
- `unit/*.tftest.hcl` - Native Terraform unit tests

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Minimal namespace on a temporary AKS cluster
- `fixtures/complete/` - Namespace with labels, annotations, and wait setting
- `fixtures/secure/` - Namespace with security annotations
- `fixtures/negative/` - Negative test cases

## Test Scenarios

### Basic Tests (`-short` flag)

- Module deployment and destruction
- Basic functionality validation
- Output verification
- Resource naming validation

### Integration Tests

- Idempotency checks for the basic fixture

### Performance Tests

- Resource creation time tracking

## Debugging Tests

### Verbose Output

```bash
go test -v -run TestBasicKubernetesNamespace
```

### Keep Resources After Test Failure

Set the `SKIP_TEARDOWN` environment variable:

```bash
export SKIP_TEARDOWN=true
go test -v -run TestBasicKubernetesNamespace
```

### Debug Terraform

Enable Terraform debug logging:

```bash
export TF_LOG=DEBUG
go test -v -run TestBasicKubernetesNamespace
```
