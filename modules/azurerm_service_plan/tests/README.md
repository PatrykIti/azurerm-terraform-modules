# App Service Plan Module Tests

This directory contains automated tests for the App Service Plan Terraform
module using [Terratest](https://terratest.gruntwork.io/).

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

## Test Structure

### Test Files

- `service_plan_test.go` - Main module functionality tests
- `integration_test.go` - Integration tests with live Azure resources
- `performance_test.go` - Performance and load tests
- `test_helpers.go` - Common test utilities and ARM REST helper
- `test_config.yaml` - Test configuration and scenarios

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Premium plan with diagnostics and zonal balancing
- `fixtures/secure/` - Operationally hardened baseline
- `fixtures/elastic/` - Elastic Premium scaling scenario
- `fixtures/negative/` - Negative validation case

## Debugging Tests

### Verbose Output

```bash
go test -v -run TestBasicServicePlan
```

### Keep Resources After Test Failure

Set the `SKIP_TEARDOWN` environment variable:

```bash
export SKIP_TEARDOWN=true
go test -v -run TestBasicServicePlan
```

### Debug Terraform

Enable Terraform debug logging:

```bash
export TF_LOG=DEBUG
go test -v -run TestBasicServicePlan
```
