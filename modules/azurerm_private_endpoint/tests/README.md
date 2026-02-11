# Private Endpoint Module Tests

This directory contains automated tests for the Private Endpoint Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later (matches module baseline in `../versions.tf`)
3. **Azure CLI**: Authenticated with appropriate permissions
4. **Azure Service Principal**: With Contributor access to the test subscription

## Environment Variables

Set either `ARM_*` or `AZURE_*` credentials before running tests. The test Makefile normalizes both forms.

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_LOCATION="northeurope"  # Optional, defaults to northeurope in test helpers
```

Equivalent `AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`, and `AZURE_CLIENT_SECRET` variables are also supported.

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

### Run Complete/Secure Tests

```bash
make test-complete
make test-secure
```

### Run Validation Tests

```bash
make test-validation
```

### Run Integration Tests

```bash
make test-integration
```

### Run Performance Tests

```bash
make test-performance
```

### Run Specific Test

```bash
go test -v -run TestBasicPrivateEndpoint -timeout 30m
```

## Test Structure

### Test Files

- `private_endpoint_test.go` - Basic/complete/secure coverage and negative validation test
- `integration_test.go` - Integration tests for DNS zone groups and static IP configuration
- `performance_test.go` - Performance and benchmark tests
- `test_helpers.go` - Common test utilities and helpers
- `test_config.yaml` - Test configuration and scenarios

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Complete feature demonstration (DNS group + IP config)
- `fixtures/secure/` - Security-focused configuration (public access disabled)
- `fixtures/ip-configuration/` - Static IP configuration scenario
- `fixtures/private-dns-zone-group/` - DNS zone group attachment scenario
- `fixtures/negative/` - Negative test cases (validation failures)

## Debugging Tests

### Verbose Output

```bash
go test -v -run TestCompletePrivateEndpoint
```

### Keep Resources After Test Failure

Set the `SKIP_TEARDOWN` environment variable:

```bash
export SKIP_TEARDOWN=true
```
