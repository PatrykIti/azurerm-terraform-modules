# Azure Storage Account Module Documentation

Additional documentation for the Azure Storage Account Terraform module.

## Main Documentation

- [`../README.md`](../README.md) - Main module documentation and usage
- [`IMPORT.md`](IMPORT.md) - Import existing storage accounts using Terraform import blocks
- [`../SECURITY.md`](../SECURITY.md) - Security features and hardening guidance
- [`../CHANGELOG.md`](../CHANGELOG.md) - Version history
- [`../CONTRIBUTING.md`](../CONTRIBUTING.md) - Contribution guidelines
- [`../VERSIONING.md`](../VERSIONING.md) - Versioning strategy

## Examples

- [`../examples/basic/`](../examples/basic/) - Minimal, secure defaults
- [`../examples/complete/`](../examples/complete/) - Full feature coverage
- [`../examples/secure/`](../examples/secure/) - Hardened configuration
- [`../examples/secure-private-endpoint/`](../examples/secure-private-endpoint/) - Private endpoints and security controls
- [`../examples/data-lake-gen2/`](../examples/data-lake-gen2/) - ADLS Gen2 with SFTP/NFS
- [`../examples/advanced-policies/`](../examples/advanced-policies/) - SAS/immutability/routing policies
- [`../examples/identity-access/`](../examples/identity-access/) - Managed identities and keyless auth
- [`../examples/multi-region/`](../examples/multi-region/) - Multi-region replication patterns

## Quick Start

```hcl
module "storage" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.2.2"

  name                = "mystorageaccount"
  resource_group_name = "my-resource-group"
  location            = "westeurope"
}
```

## Generate Documentation

```bash
cd ..
./generate-docs.sh
# or from repo root:
./scripts/update-module-docs.sh azurerm_storage_account
```

## Run Examples

```bash
cd ../examples/basic
terraform init
terraform plan
```
