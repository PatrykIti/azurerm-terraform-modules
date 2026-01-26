# Monitor Data Collection Rule Module Tests

This directory contains automated tests for the Monitor Data Collection Rule Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.3.0 or later
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

### Common Make Targets

```bash
make test
make test-basic
make test-complete
make test-secure
make test-validation
make test-integration
make test-performance
```

### Run Specific Test

```bash
go test -v -run TestBasicMonitorDataCollectionRule -timeout 30m
```

## Test Structure

### Test Files

- `monitor_data_collection_rule_test.go` - Main module functionality tests
- `integration_test.go` - Integration tests
- `performance_test.go` - Performance tests
- `test_helpers.go` - Common test utilities and helpers
- `test_config.yaml` - Test configuration and scenarios

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Complete feature demonstration
- `fixtures/secure/` - Security-focused configuration
- `fixtures/negative/` - Negative test cases

## Contributing

When adding new tests:

1. Follow the existing test structure and naming conventions
2. Add appropriate fixtures in the `fixtures/` directory
3. Update `test_config.yaml` if adding new scenarios
4. Ensure tests are idempotent and clean up resources
