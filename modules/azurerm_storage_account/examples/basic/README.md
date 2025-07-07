# Basic Storage Account Example

This example demonstrates a basic Azure Storage Account configuration using secure defaults and minimal setup.

## Features

- Creates a basic storage account with Standard tier and LRS replication
- Uses secure defaults (shared access keys disabled by default)
- Creates a dedicated resource group for the storage account
- Demonstrates container creation using the module's containers parameter
- Uses variables for configuration flexibility

## Key Configuration

This example uses secure defaults with shared access keys disabled. It demonstrates:
- Creating a storage container using the module's `containers` parameter
- Using variables for easy configuration customization
- Following security best practices by default

To enable shared access keys (for development or legacy compatibility), uncomment the security_settings block in main.tf.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Requirements

- Azure subscription
- Terraform >= 1.3.0
- AzureRM Provider 4.35.0 (as specified in the module's [versions.tf](../../versions.tf))

**Note**: The module uses a pinned version of the AzureRM provider (4.35.0) to ensure consistent behavior across all deployments.

## Outputs

- `storage_account_id` - The ID of the created storage account
- `storage_account_name` - The name of the created storage account
- `primary_blob_endpoint` - The primary blob storage endpoint URL
- `primary_connection_string` - The primary connection string (only available when shared access keys are enabled)
- `primary_access_key` - The primary access key (only available when shared access keys are enabled)
- `resource_group_name` - The name of the resource group
- `location` - The Azure location where resources are deployed