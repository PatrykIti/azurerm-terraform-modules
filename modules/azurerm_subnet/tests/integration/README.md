# Azure Subnet Module - Integration Tests

This directory contains Terratest integration tests for the Azure Subnet module.

## Prerequisites

1. **Go 1.21+** installed
2. **Azure Service Principal** with appropriate permissions
3. **Environment Variables** configured (see below)

## Environment Variables

Required environment variables:

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
```

Optional environment variables:

```bash
export ARM_TEST_LOCATION="northeurope"  # Default: northeurope
export TF_BACKEND_RESOURCE_GROUP=""     # For remote state (optional)
export TF_BACKEND_STORAGE_ACCOUNT=""    # For remote state (optional)
export TF_BACKEND_CONTAINER=""          # For remote state (optional)
```

## Running Tests

### Run all tests
```bash
make test
```

### Run specific test
```bash
make test-basic
make test-complete
make test-secure
make test-private-endpoint
```

### Run with custom timeout
```bash
TIMEOUT=45m make test
```

### Validate environment
```bash
make validate-env
```

## Test Structure

- `subnet_test.go` - Main test file containing all test cases
- `test_helpers.go` - Helper functions and utilities
- `Makefile` - Build and test automation

## Test Cases

### TestSubnetBasic
Tests basic subnet creation with minimal configuration:
- Creates a subnet with default settings
- Verifies subnet exists in Azure
- Validates outputs

### TestSubnetComplete
Tests subnet with all features enabled:
- NSG association
- Route table association
- Service endpoints
- Service endpoint policies
- Delegations

### TestSubnetSecure
Tests secure subnet configuration:
- Restrictive NSG rules
- Custom route table with firewall routing
- Service endpoint policies
- Security-focused settings

### TestSubnetPrivateEndpoint
Tests subnet configured for private endpoints:
- Network policies disabled
- Private endpoint creation
- Validates configuration for private endpoints

## Debugging

To run tests with verbose output:
```bash
go test -v
```

To run a specific test with debugging:
```bash
go test -v -run TestSubnetBasic
```

## Cleanup

Tests automatically clean up resources after completion. If cleanup fails, resources will be tagged with the test run ID for manual cleanup.

## Contributing

When adding new tests:
1. Follow the existing test pattern
2. Use unique resource names with random suffixes
3. Always defer cleanup with `terraform.Destroy()`
4. Add appropriate assertions for Azure resources
5. Update this README with new test information