# Complete Subnet Example

This example demonstrates a comprehensive subnet configuration with service endpoints, service endpoint policies, and security associations.

## Features

- Resource group, virtual network, and subnet with multiple address prefixes.
- Service endpoints for common Azure services.
- Service endpoint policy for storage access control.
- Network Security Group and Route Table associations.
- Storage account used for the policy demonstration.

## Architecture

```
Resource Group
├── Virtual Network (10.0.0.0/16)
│   └── Subnet (10.0.1.0/24, 10.0.2.0/24)
├── Network Security Group
├── Route Table
├── Service Endpoint Policy
└── Storage Account
```

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```
2. Review and apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Cleanup

```bash
terraform destroy
```

## Notes

- Update `storage_account_name` if the default is already taken.
- Replace the virtual appliance IP (`10.0.10.4`) with your actual routing target.

## Example terraform.tfvars

```hcl
location = "West Europe"
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
