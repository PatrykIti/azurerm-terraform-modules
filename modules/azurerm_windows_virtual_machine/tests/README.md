# Windows Virtual Machine Module Tests

This directory contains automated tests for the Windows Virtual Machine module
using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

- Go 1.21+
- Terraform >= 1.12.2
- Azure CLI authenticated
- Azure credentials exported as environment variables

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
make test-all
make test-short
make test-integration
```

Run a specific test:

```bash
go test -v -run TestBasicWindowsVirtualMachine -timeout 30m
```

## Fixtures

The `fixtures/` directory includes:

- `basic/` - Minimal valid configuration
- `complete/` - Full feature coverage (extensions + diagnostics)
- `secure/` - No public IP and restricted RDP
- `data-disks/` - Managed data disks attachment
- `vm-extensions/` - VM extension deployment
- `network/` - Additional network scenario
- `negative/` - Validation failure scenario

## Notes

- Integration tests create real Azure resources and may incur cost.
- Use `SKIP_TEARDOWN=true` to retain resources for debugging.
