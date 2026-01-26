# PostgreSQL Flexible Server Database Module Tests

This directory contains automated tests for the PostgreSQL Flexible Server
Database module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

1. **Go**: Version 1.21 or later
2. **Terraform**: Version 1.12.2 or later
3. **Azure CLI**: Authenticated with appropriate permissions
4. **Azure Service Principal**: With Contributor access to the test subscription

## Environment Variables

Set the following environment variables before running integration tests:

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
```

## Running Tests

```bash
go mod download
make test-all
```

## Test Structure

### Test Files

- `postgresql_flexible_server_database_test.go` - Basic, complete, secure, and negative tests
- `integration_test.go` - Full integration and lifecycle tests
- `performance_test.go` - Performance checks
- `test_helpers.go` - Common utilities

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Database with charset/collation
- `fixtures/secure/` - Private networking via server module
- `fixtures/negative/` - Invalid inputs to validate failures

## Troubleshooting

Common issues:

1. **Authentication errors**: Verify ARM\_* environment variables
2. **Resource conflicts**: Ensure unique resource naming or wait for Azure deletes
3. **Timeouts**: Re-run tests if Azure is throttling or deleting resources
