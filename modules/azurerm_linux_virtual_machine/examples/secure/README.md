# Secure Linux Virtual Machine Example

This example demonstrates a security-focused Linux VM deployment without public IP exposure.

## Features

- Private subnet with no public IP
- SSH key authentication only
- Secure Boot, vTPM, and encryption at host enabled
- Managed boot diagnostics

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
