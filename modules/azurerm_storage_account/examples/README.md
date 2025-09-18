# Storage Account Module Examples

This directory contains examples showing how to use the Storage Account module in various scenarios.

## Available Examples

- **[simple](./simple/README.md)** - Basic storage account with minimal configuration
- **[secure](./secure/README.md)** - Security-hardened configuration
- **[secure-private-endpoint](./secure-private-endpoint/README.md)** - Private endpoint configuration
- **[data-lake-gen2](./data-lake-gen2/README.md)** - Data Lake Storage Gen2 with SFTP and NFSv3
- **[advanced-policies](./advanced-policies/README.md)** - Advanced policies (SAS, immutability, routing)
- **[identity-access](./identity-access/README.md)** - Microsoft Entra ID authentication and RBAC
- **[complete](./complete/README.md)** - Comprehensive example with all features enabled
- **[multi-region](./multi-region/README.md)** - Multi-region deployment with replication

## Important Note on Module Source

### For Development/Testing
When testing these examples locally during development, the examples use relative paths:
```hcl
module "storage_account" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0"
  # ...
}
```

### For Production Use
In your actual Terraform configurations, you should reference the module using a Git URL with a specific version tag:
```hcl
module "storage_account" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0"
  # ...
}
```

**Note**: After each release, the examples in this repository are automatically updated to show the latest version tag. This ensures that the examples always demonstrate best practices for production usage.

## Provider Version Requirements

**Important**: This module requires specific provider versions as defined in the module's [versions.tf](../versions.tf):
- **Terraform**: >= 1.3.0
- **AzureRM Provider**: 4.43.0 (pinned version)

The examples inherit these version constraints from the module. While you can override them in your root configuration, it's recommended to use the same versions for compatibility.

## Running the Examples

1. Navigate to the example directory:
   ```bash
   cd simple
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. Clean up resources:
   ```bash
   terraform destroy
   ```

## Authentication

The examples assume you have authenticated to Azure. You can authenticate using:

- Azure CLI: `az login`
- Service Principal: Set environment variables
- Managed Identity: When running in Azure

For more details, see the [AzureRM Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure).