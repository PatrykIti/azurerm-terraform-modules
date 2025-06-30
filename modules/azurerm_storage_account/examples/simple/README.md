# Simple Storage Account Example

This example demonstrates the basic usage of the Azure Storage Account module with minimal configuration.

## Features

- Creates a basic storage account with Standard tier and LRS replication
- Uses default security settings (HTTPS-only, TLS 1.2)
- Generates a unique storage account name using random suffix

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Requirements

- Azure subscription
- Terraform >= 1.3.0
- AzureRM Provider >= 3.0.0

## Outputs

- `storage_account_id` - The ID of the created storage account
- `storage_account_name` - The name of the created storage account
- `primary_blob_endpoint` - The primary blob storage endpoint URL
- `primary_connection_string` - The primary connection string (sensitive)