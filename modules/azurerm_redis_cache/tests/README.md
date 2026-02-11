# Redis Cache Module Tests

This directory contains automated tests for the Redis Cache Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure CLI**: Authenticated with appropriate permissions
4. **Azure Service Principal**: Contributor access to the test subscription

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

### Run Targeted Tests

```bash
make test-basic
make test-complete
make test-secure
make test-patch-schedule
make test-firewall-rules
make test-linked-server
make test-integration
make test-performance
```

### Run a Specific Test

```bash
go test -v -run TestRedisCacheLinkedServer -timeout 45m
```

## Test Fixtures

The `fixtures/` directory contains Terraform configurations for different scenarios:

- `fixtures/basic/` - Basic Redis Cache configuration
- `fixtures/complete/` - Full feature configuration with diagnostics and persistence
- `fixtures/secure/` - VNet injection with public access disabled
- `fixtures/patch-schedule/` - Patch schedule configuration
- `fixtures/firewall-rules/` - Public access with firewall rules
- `fixtures/linked-server/` - Linked server configuration

## Notes

- The fixtures use random suffixes to avoid naming collisions.
- Performance tests are skipped when `-short` is set.
- Update `test_config.yaml` when adding new scenarios.
