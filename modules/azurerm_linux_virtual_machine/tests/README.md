# Linux Virtual Machine Module Tests

This directory contains automated tests for the Linux Virtual Machine Terraform module using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

- Go 1.21+
- Terraform 1.12+
- Azure credentials with Contributor access

## Environment Variables

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_LOCATION="West Europe"  # Optional
```

## Running Tests

```bash
make test
make test-basic
make test-complete
make test-secure
make test-data-disks
make test-extensions
make test-integration
```

## Fixtures

- `fixtures/basic/` - Minimal VM configuration
- `fixtures/complete/` - Full feature set (diagnostics, extensions, identity)
- `fixtures/secure/` - Security-hardened configuration
- `fixtures/data-disks/` - Multiple data disks
- `fixtures/vm-extensions/` - VM extensions
