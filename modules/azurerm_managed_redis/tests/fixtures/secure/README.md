# Secure Managed Redis Example

This example demonstrates a maximum-security Managed Redis configuration suitable for highly sensitive data and regulated environments.

## Features

- Maximum security configuration with all security features enabled
- Public network access disabled with CMK and user-assigned identity
- Advanced threat protection
- Comprehensive audit logging and monitoring
- Encryption at rest and in transit
- Compliance-ready configuration

## Key Configuration

This example implements defense-in-depth security principles with multiple layers of protection suitable for highly regulated industries and sensitive workloads.

## Security Considerations

- All public access is disabled by default
- Private connectivity should be added outside this module if clients need network access
- All data is encrypted at rest and in transit
- Audit logging captures all access and modifications

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
