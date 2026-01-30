# Secure Bastion Host Example

This example demonstrates a hardened Bastion Host configuration with restricted features and a dedicated subnet NSG.

## Features

- Standard SKU with all optional remote features disabled.
- `AzureBastionSubnet` protected by a Network Security Group with the recommended Bastion rules.
- Explicit public IP creation (required for public Bastion SKUs).

## Notes

- User-defined routes (UDR) are not supported on the Bastion subnet. This example does not attach a route table.
- If you modify NSG rules, follow Microsoft guidance to avoid breaking the Bastion service.

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
