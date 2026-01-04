# Private Endpoint Virtual Network Example

This example demonstrates a Virtual Network configuration with private endpoint connectivity for enhanced security and network isolation.

## Features

- Creates a VNet with subnets for private endpoints and workloads
- Creates a storage account with public access disabled
- Adds a private endpoint and private DNS zone for blob access
- Demonstrates private connectivity patterns outside the module

## Key Configuration

This example showcases private endpoint implementation with complete network isolation, suitable for enterprise environments requiring secure connectivity without public internet exposure.

## Network Architecture

- Virtual Network with dedicated subnet for private endpoints
- Private endpoint connection to the storage account
- DNS resolution for private connectivity

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Cleanup

```bash
terraform destroy
```

## Notes

- `storage_account_name` must be globally unique. Override the default if needed.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
