# Simple Storage Account Example

This example demonstrates the minimal configuration required to create a functional Azure Storage Account with shared key access enabled for user access.

## Features

- Creates a basic storage account with Standard tier and LRS replication
- Explicitly enables shared access keys for user authentication
- Creates a dedicated resource group for the storage account
- Uses minimal configuration while maintaining functionality

## Key Configuration

This example explicitly sets `shared_access_key_enabled = true` in the security settings to allow traditional authentication methods. This is suitable for:
- Development environments
- Applications requiring connection string authentication
- Scenarios where Azure AD authentication is not yet implemented

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
- `primary_connection_string` - The primary connection string (sensitive)
- `primary_access_key` - The primary access key (sensitive)
- `resource_group_name` - The name of the resource group
- `location` - The Azure location where resources are deployed