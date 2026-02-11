# Import existing Private DNS Zone Virtual Network Link into the module (Terraform import blocks)

This guide shows how to import an existing Private DNS Zone Virtual Network Link into
`modules/azurerm_private_dns_zone_virtual_network_link` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI authenticated (`az login`)
- Existing link name, private DNS zone name, resource group, and subscription

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

module "private_dns_zone_virtual_network_link" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_private_dns_zone_virtual_network_link?ref=PDNSZLNKv1.0.0"

  name                  = var.link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
}
```

---

## 2) Add the import block

Create `import.tf` with the import block:

```hcl
import {
  to = module.private_dns_zone_virtual_network_link.azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/<zone>/virtualNetworkLinks/<link>"
}
```

Get the ID with Azure CLI:

```bash
az network private-dns link vnet show -g <rg> -z <zone> -n <link> --query id -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

After a clean plan, you can remove the import block.
