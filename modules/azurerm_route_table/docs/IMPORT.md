# Import existing Route Table into the module (Terraform import blocks)

This guide shows how to import an existing Azure Route Table into
`modules/azurerm_route_table` using Terraform **import blocks**.

The flow is based on the **basic example** and keeps only the **module block**
in the configuration (no extra Terraform resources required).

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI logged in (`az login`)
- You know the **route table name**, **resource group**, and **subscription**

---

## 1) Prepare a minimal config (module block only)

Create `main.tf` and keep just the **module block**. Replace values with your
existing Route Table settings.

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

module "route_table" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_route_table?ref=RTv1.0.3"

  name                = var.route_table_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Optional: manage existing routes
  # routes = [
  #   {
  #     name                   = "to-internet"
  #     address_prefix         = "0.0.0.0/0"
  #     next_hop_type          = "Internet"
  #   }
  # ]
}
```

Create `terraform.tfvars` with real values:

```hcl
route_table_name   = "rt-prod"
resource_group_name = "rg-network-prod"
location            = "westeurope"
```

Get current values with Azure CLI:

```bash
az network route-table show -g <rg> -n <rt> --query '{name:name,location:location}' -o table
```

---

## 2) Add the import block(s)

Create `import.tf` with the Route Table import block:

```hcl
import {
  to = module.route_table.azurerm_route_table.route_table
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/routeTables/<rt_name>"
}
```

To get the **exact ID**:

```bash
az network route-table show -g <rg> -n <rt> --query id -o tsv
```

### Optional imports (routes)

If you want the module to **manage existing routes**, define them in `routes`
and import each route:

```hcl
import {
  to = module.route_table.azurerm_route.routes["to-internet"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/routeTables/<rt>/routes/to-internet"
}
```

To get route IDs:

```bash
az network route-table route show -g <rg> --route-table-name <rt> -n <route> --query id -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected output in `plan`:
- one **import** action for the Route Table
- **no other changes** (unless you plan to manage routes)

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg route_table
```

If the plan is clean, you can **remove the import block** (`import.tf`).

---

## Common errors and fixes

- **Import does nothing**: import blocks run only on `terraform apply`. Run `plan` then `apply`.
- **Resource not found**: wrong ID or subscription. Use `az account show` and `az network route-table show -g <rg> -n <rt> --query id -o tsv`.
- **Plan shows changes after import**: inputs do not match existing Route Table.
- **Routes not managed**: if you want route management, define `routes` and import each one.
