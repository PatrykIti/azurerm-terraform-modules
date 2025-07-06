# Storage Account Module Examples

This directory contains examples showing how to use the Storage Account module in various scenarios.

## Available Examples

- **[simple](./simple)** - Basic storage account with minimal configuration
- **[complete](./complete)** - Comprehensive example with all features enabled
- **[secure](./secure)** - Security-hardened configuration
- **[secure-private-endpoint](./secure-private-endpoint)** - Private endpoint configuration
- **[multi-region](./multi-region)** - Multi-region deployment with replication

## Important Note on Module Source

### For Development/Testing
When testing these examples locally during development, the examples use relative paths:
```hcl
module "storage_account" {
  source = "../../"
  # ...
}
```

### For Production Use
In your actual Terraform configurations, you should reference the module using a Git URL with a specific version tag:
```hcl
module "storage_account" {
  source = "github.com/yourusername/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0"
  # ...
}
```

**Note**: After each release, the examples in this repository are automatically updated to show the latest version tag. This ensures that the examples always demonstrate best practices for production usage.

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