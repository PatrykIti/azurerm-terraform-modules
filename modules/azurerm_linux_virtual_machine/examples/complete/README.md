# Complete Linux Virtual Machine Example

This example demonstrates a Linux VM with data disks, boot diagnostics, managed identity, extensions, and diagnostic settings.

## Features

- Data disks with Premium storage
- Boot diagnostics with a storage account
- User-assigned managed identity
- VM extension (Custom Script)
- Diagnostic settings with Log Analytics
- Cloud-init custom data

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
