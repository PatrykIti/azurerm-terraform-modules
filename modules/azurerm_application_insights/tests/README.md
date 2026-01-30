# Application Insights Module Tests

This directory contains automated tests for the Application Insights Terraform module using [Terratest](https://terratest.gruntwork.io/).

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
export ARM_LOCATION="westeurope"  # Optional, defaults to westeurope
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

### Run Feature-Specific Tests

```bash
make test-api-keys
make test-analytics-items
make test-web-tests
make test-standard-web-tests
make test-workbooks
make test-smart-detection
```

### Run Specific Test

```bash
go test -v -run TestCompleteApplicationInsights -timeout 30m
```

## Test Structure

### Test Files

- `application_insights_test.go` - Primary module tests
- `integration_test.go` - Integration tests with other Azure services
- `performance_test.go` - Performance and load tests
- `test_helpers.go` - Common test utilities and helpers
- `test_config.yaml` - Test configuration and scenarios

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Full feature configuration
- `fixtures/secure/` - Security-focused configuration
- `fixtures/api-keys/` - API keys configuration
- `fixtures/analytics-items/` - Analytics items configuration
- `fixtures/web-tests/` - Classic web tests configuration
- `fixtures/standard-web-tests/` - Standard web tests configuration
- `fixtures/workbooks/` - Workbooks configuration
- `fixtures/smart-detection-rules/` - Smart detection rules configuration
- `fixtures/negative/` - Negative validation test cases

## Debugging Tests

### Verbose Output

```bash
go test -v -run TestBasicApplicationInsights
```

### Keep Resources After Test Failure

Set the `SKIP_TEARDOWN` environment variable:

```bash
export SKIP_TEARDOWN=true
go test -v -run TestBasicApplicationInsights
```

### Debug Terraform

Enable Terraform debug logging:

```bash
export TF_LOG=DEBUG
go test -v -run TestBasicApplicationInsights
```

## Contributing

When adding new tests:

1. Follow the existing test structure and naming conventions
2. Add appropriate fixtures in the `fixtures/` directory
3. Update `test_config.yaml` if adding new scenarios
4. Ensure tests are idempotent and clean up resources
