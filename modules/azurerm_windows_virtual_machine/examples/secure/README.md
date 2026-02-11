# Secure Windows Virtual Machine Example

This example demonstrates a hardened Windows VM deployment without a public IP
and with restricted RDP access via an NSG.

## Features

- No public IP address
- NSG restricting RDP to trusted CIDRs
- Trusted Launch options enabled
- Boot diagnostics enabled

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
