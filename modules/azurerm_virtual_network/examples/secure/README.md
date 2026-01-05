# Secure Virtual Network Example

This example demonstrates a security-focused Virtual Network configuration suitable for sensitive environments.

## Features

- DDoS protection plan association
- Encryption enforcement for the VNet
- Diagnostic settings for monitoring (external resource)
- Secure storage account settings for diagnostics

## Key Configuration

This example focuses on VNet-level security controls and shows how to attach monitoring outside the module.

## Security Considerations

- DDoS plan is required for protection at the VNet level
- Encryption enforcement is enabled on the VNet
- Monitoring is configured with diagnostic settings outside the module

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
- Azure allows one DDoS plan per region. Use an existing plan if one already exists.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
