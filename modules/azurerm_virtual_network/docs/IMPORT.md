# Import existing Virtual Network into the module (Terraform import blocks)

This guide shows how to import an existing Azure Virtual Network into
`modules/azurerm_virtual_network` using Terraform import blocks.

The flow uses a minimal configuration with only the module block.

---

## Requirements

- Terraform >= 1.5 (import blocks) and module requirement >= 1.12.2
- Azure CLI logged in (`az login`)
- Virtual Network name, resource group, and subscription ID

---

## 1) Prepare a minimal config (module block only)

Create `main.tf` and keep only the module block. Replace values with your
existing VNet settings.

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

module "virtual_network" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_virtual_network?ref=VNv1.1.4"

  name                = "vnet-existing"
  resource_group_name = "rg-existing"
  location            = "westeurope"
  address_space       = ["10.0.0.0/16"]
}
```

Get current values with Azure CLI:

```bash
az network vnet show -g <rg> -n <vnet> --query '{name:name,location:location,addressSpace:addressSpace.addressPrefixes}' -o table
```

---

## 2) Add the import block

Create `import.tf` with the import block:

```hcl
import {
  to = module.virtual_network.azurerm_virtual_network.virtual_network
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet_name>"
}
```

To get the exact ID:

```bash
az network vnet show -g <rg> -n <vnet> --query id -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected output in `plan`:
- one import action for the VNet
- no other changes if inputs match the existing resource

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg virtual_network
```

If the plan is clean, you can remove the import block (`import.tf`).

---

## Common errors and fixes

- Import does nothing: import blocks run only on `terraform apply`.
- Resource not found: verify subscription ID and resource group.
- Plan shows changes: inputs do not match the existing VNet settings.
