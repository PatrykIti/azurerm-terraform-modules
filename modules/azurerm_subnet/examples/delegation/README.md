# Subnet Delegation Example

This example demonstrates subnet delegation for multiple Azure services and includes one regular subnet for comparison.

## Features

- Five subnets with different delegation configurations.
- Delegation-specific network policy settings.
- An Azure Container Instance deployed into the delegated subnet.

## Architecture

```
Resource Group
└── Virtual Network (10.0.0.0/16)
    ├── Subnet (Container Instances) 10.0.1.0/24
    ├── Subnet (PostgreSQL)          10.0.2.0/24
    ├── Subnet (App Service)         10.0.3.0/24
    ├── Subnet (Batch)               10.0.4.0/24
    └── Subnet (Regular)             10.0.5.0/24
```

## Delegation Summary

| Subnet | Delegation | Network Policies |
| --- | --- | --- |
| Container Instances | `Microsoft.ContainerInstance/containerGroups` | Enabled |
| PostgreSQL Flexible | `Microsoft.DBforPostgreSQL/flexibleServers` | Disabled |
| App Service | `Microsoft.Web/serverFarms` | Enabled |
| Batch | `Microsoft.Batch/batchAccounts` | Enabled |
| Regular | None | Enabled |

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

- Each subnet can only be delegated to a single Azure service.
- Database delegations require private endpoint network policies to be disabled.
- Use dedicated subnets for delegated services to avoid overlapping responsibilities.

## Optional Validation

```bash
az network vnet subnet show \
  --resource-group rg-subnet-delegation-example \
  --vnet-name vnet-subnet-delegation-example \
  --name snet-subnet-delegation-container-instances-example
```

## Example terraform.tfvars

```hcl
location = "West Europe"
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
