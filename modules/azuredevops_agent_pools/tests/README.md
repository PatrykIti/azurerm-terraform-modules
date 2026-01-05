# Azure DevOps Agent Pools Module Tests

This directory contains automated tests for the Azure DevOps Agent Pools Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure DevOps Organization**: Access with a Personal Access Token (PAT)

## Environment Variables

Set the following environment variables before running tests:

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/your-org"
export AZDO_PERSONAL_ACCESS_TOKEN="your-pat"
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

### Run Integration Tests Only

```bash
make test-integration
```

### Run Specific Test

```bash
go test -v -run TestBasicAzuredevopsAgentPools -timeout 30m
```

## Test Structure

### Test Files

- `azuredevops_agent_pools_test.go` - Basic, complete, and secure tests
- `integration_test.go` - Full apply test using the complete fixture
- `performance_test.go` - Benchmarks are disabled by default

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Module pool with non-default settings
- `fixtures/secure/` - Security-focused configuration

## Debugging Tests

### Verbose Output

```bash
go test -v -run TestBasicAzuredevopsAgentPools
```

### Keep Resources After Test Failure

Set the `SKIP_TEARDOWN` environment variable:

```bash
export SKIP_TEARDOWN=true
go test -v -run TestBasicAzuredevopsAgentPools
```

### Debug Terraform

Enable Terraform debug logging:

```bash
export TF_LOG=DEBUG
go test -v -run TestBasicAzuredevopsAgentPools
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

## Troubleshooting

### Common Issues

1. **Authentication Errors**: Verify Azure DevOps PAT and organization URL
2. **Resource Conflicts**: Ensure unique pool naming
3. **Timeout Issues**: Increase test timeouts for larger orgs

### Getting Help

- Check the [Terratest documentation](https://terratest.gruntwork.io/)
- Review Azure DevOps provider documentation
- Check module-specific troubleshooting in the main README
