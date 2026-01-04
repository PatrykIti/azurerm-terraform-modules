# Complete Virtual Network Example

This example demonstrates a comprehensive deployment of Virtual Network with all available features and configurations.

## Features

- VNet configuration with custom DNS and multiple address spaces
- Peering to a second VNet (external resource)
- Private DNS zone link (external resource)
- Diagnostic settings for monitoring (external resource)

## Key Configuration

This example focuses on VNet configuration and demonstrates how to attach peering, private DNS, and diagnostic settings outside the module.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Notes

- `storage_account_name` must be globally unique. Override the default if needed.

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
