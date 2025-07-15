# Virtual Network Module Tests

This directory contains automated tests for the Virtual Network Terraform module using [Terratest](https://terratest.gruntwork.io/).

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

### Using Make

```bash
# Install dependencies
make deps

# Run all tests
make test

# Run specific test
make test-single TEST_NAME=TestVirtualNetworkBasic

# Run basic tests only
make test-basic

# Run complete tests
make test-complete

# Run security tests
make test-secure

# Run network tests
make test-network

# Run validation tests
make test-validation

# Run tests with coverage
make test-coverage

# Run benchmarks
make benchmark

# Clean test artifacts
make clean
```

### Direct Go Commands

```bash
# Run all tests
go test -v -timeout 30m ./...

# Run specific test
go test -v -timeout 30m -run TestVirtualNetworkBasic ./...

# Run with race detection
go test -v -race ./...
```

## Test Structure

### Test Files

- `module_test.go` - Main module functionality tests
- `virtual_network_test.go` - Consolidated test suite with staged execution
- `integration_test.go` - Integration tests (peering, DNS, flow logs)
- `performance_test.go` - Performance benchmarks and scaling tests
- `test_helpers.go` - Common test utilities and Azure client helpers
- `test_config.yaml` - CI/CD test configuration
- `Makefile` - Test automation and convenience commands

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Complete feature demonstration
- `fixtures/secure/` - Security-focused configuration
- `fixtures/private_endpoint/` - Private endpoint configuration
- `fixtures/network/` - Network integration tests
- `fixtures/negative/` - Negative test cases

## Test Scenarios

### Basic Tests (`TestVirtualNetworkBasic`)

- Module deployment and destruction
- Basic functionality validation
- Output verification
- Resource naming validation

### Complete Tests (`TestVirtualNetworkComplete`)

- All module features
- Virtual Network peering
- Private DNS zone links
- Diagnostic settings

### Security Tests (`TestVirtualNetworkSecure`)

- DDoS Protection Plan (with automatic detection)
- Network Watcher Flow Logs (with automatic detection)
- Encryption configuration
- Security monitoring

### Network Tests (`TestVirtualNetworkWithPeering`)

- Hub-spoke network topology
- Bidirectional peering
- DNS configuration
- Network flow logs

### Validation Tests (`TestVirtualNetworkValidationRules`)

- Input validation rules
- Negative test cases
- Name length and character validation
- Address space validation

### Performance Tests

- Virtual Network creation benchmarks
- Parallel deployment tests
- Large address space handling
- Scaling limits

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
5. **Network Watcher Limit**: Azure allows only one Network Watcher per region. Tests include automatic detection and reuse.
6. **DDoS Protection Plan Limit**: Azure allows only one DDoS Protection Plan per region. Tests include automatic detection and reuse.

### Getting Help

- Check the [Terratest documentation](https://terratest.gruntwork.io/)
- Review Azure provider documentation
- Check module-specific troubleshooting in the main README