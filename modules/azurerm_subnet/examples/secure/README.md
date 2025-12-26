# Secure Subnet Example

This example demonstrates a security-focused subnet configuration with restrictive NSG rules and hardened network policies.

## Features

- NSG with minimal inbound access.
- Service endpoints for Azure services.
- Network policies enabled for private endpoints and private link services.

## Architecture

```
Resource Group
├── Virtual Network (10.0.0.0/16)
│   └── Subnet (10.0.1.0/24)
└── Network Security Group
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

## Example terraform.tfvars

```hcl
location                    = "West Europe"
resource_group_name         = "rg-subnet-secure-example"
virtual_network_name        = "vnet-subnet-secure-example"
subnet_name                 = "snet-subnet-secure-example"
network_security_group_name = "nsg-subnet-secure-example"
```

<!-- BEGIN_TF_DOCS -->
<!-- This section will be populated by terraform-docs if configured -->
<!-- END_TF_DOCS -->
