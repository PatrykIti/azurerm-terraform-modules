# Secure Linux Function App Example

This example demonstrates a hardened Linux Function App configuration with
public access disabled, TLS 1.2 enforced, managed identity for storage access,
and centralized diagnostics.

## Features

- `access_configuration.public_network_access_enabled = false`
- TLS 1.2 for app and SCM endpoints
- Managed identity for storage access
- Diagnostic settings to Log Analytics

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
