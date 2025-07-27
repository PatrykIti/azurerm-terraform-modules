# Route Table Module Tests

This directory contains automated tests for the Route Table Terraform module using [Terratest](https://terratest.gruntwork.io/).

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
export ARM_LOCATION="northeurope"  # Optional, defaults to North Europe
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
go test -v -run TestBasicRouteTable -timeout 30m
```

### Run Tests in Parallel

```bash
./run_tests_parallel.sh
```

### Run Tests Sequentially

```bash
./run_tests_sequential.sh
```

## Test Structure

### Test Files

- `route_table_test.go` - Main module functionality tests
- `integration_test.go` - Integration tests with Virtual Networks and Subnets
- `performance_test.go` - Performance benchmarks and timing tests
- `test_helpers.go` - Common test utilities and helpers
- `test_config.yaml` - Test configuration and scenarios

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic route table configuration with minimal routes
- `fixtures/complete/` - Complete feature demonstration with multiple routes
- `fixtures/secure/` - Security-focused configuration with firewall routes
- `fixtures/network/` - Network integration tests with subnet associations
- `fixtures/negative/` - Negative test cases for validation rules

## Test Scenarios

### Basic Tests (`-short` flag)

- Route table creation and destruction
- Basic route configuration validation
- Output verification
- Resource naming validation
- Default route behavior

### Integration Tests

- Route table association with subnets
- Multiple route updates and lifecycle management
- Integration with Virtual Networks
- Route propagation settings
- Next hop type validations

### Performance Tests

- Route table creation time benchmarks
- Concurrent route table deployments
- Large number of routes handling
- Update performance testing

## Test Configuration

Tests are configured via `test_config.yaml`. Key configuration options:

- **Environments**: Different Azure regions and configurations
- **Scenarios**: Test case definitions and timeouts
- **Performance**: Load testing parameters
- **Integration**: Cross-service testing settings

## Debugging Tests

### Verbose Output

```bash
go test -v -run TestModuleBasic
```

### Keep Resources After Test Failure

Set the `SKIP_TEARDOWN` environment variable:

```bash
export SKIP_TEARDOWN=true
go test -v -run TestModuleBasic
```

### Debug Terraform

Enable Terraform debug logging:

```bash
export TF_LOG=DEBUG
go test -v -run TestModuleBasic
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
3. Update `test_config.yaml` if adding new scenarios
4. Ensure tests are idempotent and clean up resources
5. Add documentation for any new test scenarios

## Troubleshooting

### Common Issues

1. **Authentication Errors**: Verify Azure credentials and permissions
2. **Resource Conflicts**: Ensure unique resource naming
3. **Timeout Issues**: Increase test timeouts for complex scenarios
4. **Quota Limits**: Check Azure subscription quotas

### Getting Help

- Check the [Terratest documentation](https://terratest.gruntwork.io/)
- Review Azure provider documentation
- Check module-specific troubleshooting in the main README