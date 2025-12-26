# Basic Subnet Example

This example demonstrates a basic subnet deployment using secure defaults.

## Features

- Resource group, virtual network, and subnet creation.
- Default network policy settings.
- Simple address prefix assignment.

## Architecture

```
Resource Group
└── Virtual Network (10.0.0.0/16)
    └── Subnet (10.0.1.0/24)
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
location             = "West Europe"
resource_group_name  = "rg-subnet-basic-example"
virtual_network_name = "vnet-subnet-basic-example"
subnet_name          = "snet-subnet-basic-example"
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
