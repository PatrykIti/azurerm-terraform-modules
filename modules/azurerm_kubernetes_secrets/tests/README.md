# Kubernetes Secrets Module Tests

This directory contains automated tests for the Kubernetes Secrets Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure CLI**: Authenticated with appropriate permissions
4. **Azure Service Principal**: With Contributor access to the test subscription
5. **kubectl**: Required for `TestSecureKubernetesSecrets` to install ESO CRDs (v1.18+ for server-side apply)

## Environment Variables

Set the following environment variables before running tests:

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_LOCATION="northeurope"  # Optional, defaults to northeurope
export ESO_CRD_URL="https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/crds/bundle.yaml" # Optional override
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
go test -v -run TestBasicKubernetesSecrets -timeout 30m
```

## Test Structure

### Test Files

- `kubernetes_secrets_test.go` - Main module functionality tests
- `integration_test.go` - Lifecycle/idempotency test
- `performance_test.go` - Performance and timing tests
- `test_helpers.go` - Common test utilities and helpers
- `unit/*.tftest.hcl` - Native Terraform unit tests

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Manual strategy configuration
- `fixtures/complete/` - CSI strategy configuration
- `fixtures/secure/` - ESO strategy configuration
- `fixtures/network/` - Network scenario fixture (manual)
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
go test -v -run TestBasicKubernetesSecrets
```

### Keep Resources After Test Failure

Set the `SKIP_TEARDOWN` environment variable:

```bash
export SKIP_TEARDOWN=true
go test -v -run TestBasicKubernetesSecrets
```

### Debug Terraform

Enable Terraform debug logging:

```bash
export TF_LOG=DEBUG
go test -v -run TestBasicKubernetesSecrets
```

## Continuous Integration

Tests are automatically run in CI/CD pipelines:

- **Pull Requests**: Short tests only
- **Main Branch**: All tests including integration
- **Releases**: Full test suite including performance tests

## Contributing

When adding new tests:

1. Follow the existing test structure and naming conventions
2. Add appropriate fixtures in the `fixtures/` directory
3. Ensure tests are idempotent and clean up resources
4. Update this README if you add new scenarios
