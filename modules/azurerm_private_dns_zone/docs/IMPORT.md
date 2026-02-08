# Import existing Private DNS Zone into the module (Terraform import blocks)

This guide shows how to import an existing Private DNS Zone into
`modules/azurerm_private_dns_zone` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI authenticated (`az login`)
- Existing Private DNS Zone name, resource group, and subscription

---

## 1) Minimal configuration

Create a minimal `main.tf` with the module only:

```hcl
terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "private_dns_zone" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_private_dns_zone?ref=PDNSZv1.0.0"

  name                = var.zone_name
  resource_group_name = var.resource_group_name
}
```

---

## 2) Add the import block

Create `import.tf` with the import block:

```hcl
import {
  to = module.private_dns_zone.azurerm_private_dns_zone.private_dns_zone
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/<zone>"
}
```

Get the ID with Azure CLI:

```bash
az network private-dns zone show -g <rg> -n <zone> --query id -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

After a clean plan, you can remove the import block.
