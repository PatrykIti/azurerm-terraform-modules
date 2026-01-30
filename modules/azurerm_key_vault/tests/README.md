# Key Vault Module Tests

This directory contains automated tests for the Key Vault Terraform module using Terratest.

## Prerequisites

1. Go 1.21+
2. Terraform 1.12.2+
3. Azure CLI authenticated with appropriate permissions
4. Azure service principal with Contributor access to the test subscription

## Environment Variables

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_LOCATION="northeurope"  # Optional, defaults to northeurope
```

## Running Tests

```bash
go mod download
make test-all
```

Run a specific test:

```bash
go test -v -run TestBasicKeyVault -timeout 30m
```

## Test Structure

### Test Files

- `key_vault_test.go` - Core module fixture tests
- `integration_test.go` - Complete fixture integration checks
- `performance_test.go` - Performance and load tests
- `test_helpers.go` - Shared helpers
- `test_config.yaml` - Test configuration

### Test Fixtures

The `fixtures/` directory contains Terraform configurations for different scenarios:

- `fixtures/basic/` - Basic module configuration
- `fixtures/complete/` - Full feature configuration
- `fixtures/secure/` - Private endpoint + RBAC configuration
- `fixtures/network/` - Network ACL validation
- `fixtures/keys/` - Keys data-plane configuration
- `fixtures/secrets/` - Secrets data-plane configuration
- `fixtures/certificates/` - Certificates data-plane configuration
- `fixtures/diagnostic-settings/` - Diagnostic settings configuration
- `fixtures/managed-storage-account/` - Managed storage account configuration
- `fixtures/negative/` - Validation failures

## Notes

- Fixtures use randomized suffixes to avoid name collisions.
- Data-plane fixtures require access policies or RBAC roles for the test principal.
- Private endpoint fixture provisions a DNS zone and subnet; ensure appropriate Azure limits.
