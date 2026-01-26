# Secure Monitor Data Collection Endpoint Example

This example demonstrates a security-focused Data Collection Endpoint configuration with public access disabled.

## Features

- Disables public network access
- Uses explicit description and tags

## Security Considerations

- Ensure private connectivity (out of scope for this module) before disabling public access
- Configure diagnostic settings if auditing is required

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

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
