# Azure DevOps Repository Module Tests

This directory contains automated tests for the Azure DevOps Repository Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure DevOps Organization**: Access with a Personal Access Token (PAT)
4. **Azure DevOps Project**: Project ID for repository creation

## Environment Variables

Set the following environment variables before running tests:

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/your-org"
export AZDO_PERSONAL_ACCESS_TOKEN="your-pat"
export AZDO_PROJECT_ID="your-project-id"
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
go test -v -run TestBasicAzuredevopsRepository -timeout 30m
```

## Test Structure

### Test Files

- `azuredevops_repository_test.go` - Basic, complete, secure, and validation tests
- `integration_test.go` - Full apply test using the complete fixture
- `performance_test.go` - Benchmarks are disabled by default

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different test scenarios:

- `fixtures/basic/` - Basic repository with README file
- `fixtures/complete/` - Repository with branches and permissions
- `fixtures/secure/` - Repository with stricter policy configuration
- `fixtures/negative/` - Negative test cases

## Debugging Tests

### Verbose Output

```bash
go test -v -run TestBasicAzuredevopsRepository
```

### Keep Resources After Test Failure

Set the `SKIP_TEARDOWN` environment variable:

```bash
export SKIP_TEARDOWN=true
go test -v -run TestBasicAzuredevopsRepository
```

### Debug Terraform

Enable Terraform debug logging:

```bash
export TF_LOG=DEBUG
go test -v -run TestBasicAzuredevopsRepository
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
2. **Project ID Missing**: Ensure AZDO_PROJECT_ID points to an existing project
3. **Resource Conflicts**: Ensure unique repository naming
4. **Timeout Issues**: Increase test timeouts for larger orgs

### Getting Help

- Check the [Terratest documentation](https://terratest.gruntwork.io/)
- Review Azure DevOps provider documentation
- Check module-specific troubleshooting in the main README
