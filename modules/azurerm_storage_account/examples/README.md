# Storage Account Module Examples

Examples showing how to use the Storage Account module in various scenarios.

## Available Examples

- **[basic](./basic/README.md)** - Minimal storage account with secure defaults
- **[complete](./complete/README.md)** - Full feature coverage
- **[secure](./secure/README.md)** - Hardened configuration
- **[secure-private-endpoint](./secure-private-endpoint/README.md)** - Private endpoints and security controls
- **[data-lake-gen2](./data-lake-gen2/README.md)** - ADLS Gen2 with SFTP/NFS
- **[advanced-policies](./advanced-policies/README.md)** - SAS/immutability/routing policies
- **[identity-access](./identity-access/README.md)** - Managed identities and keyless auth
- **[multi-region](./multi-region/README.md)** - Multi-region replication patterns

## Module Source

### Development / local testing
Examples in this repository use a local source:
```hcl
module "storage_account" {
  source = "../.."
}
```

### Production usage
Pin a version tag from GitHub:
```hcl
module "storage_account" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.2.2"
}
```

## Provider Version Requirements

- **Terraform**: >= 1.12.2
- **AzureRM Provider**: 4.57.0

## Running the Examples

```bash
cd basic
terraform init
terraform plan
terraform apply
terraform destroy
```

## Authentication

Authenticate via Azure CLI (`az login`) or service principal environment variables.
