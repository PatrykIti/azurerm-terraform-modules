# Complete Windows Virtual Machine Example

This example demonstrates a feature-complete Windows VM deployment with data
 disks, managed identity, extensions, boot diagnostics, and diagnostic settings.

## Features

- Windows VM with managed identity
- Managed data disks attached to the VM
- Boot diagnostics enabled
- Custom script extension
- Diagnostic settings streamed to Log Analytics

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
