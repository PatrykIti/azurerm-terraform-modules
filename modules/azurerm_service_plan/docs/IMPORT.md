# Import existing App Service Plan into the module (Terraform import blocks)

This guide shows how to import an existing Azure App Service Plan into
`modules/azurerm_service_plan` using Terraform **import blocks**.

The flow keeps only the **module block** in configuration. Any diagnostic
settings you want the module to manage can be imported after their matching
inputs are added.

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI logged in (`az login`)
- The App Service Plan name, resource group, and subscription

---

## 1) Prepare a minimal config (module block only)

Create `main.tf` with only the module block and replace values with your
existing plan settings.

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

module "service_plan" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_service_plan?ref=ASPv1.0.0"

  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location

  service_plan = {
    os_type  = var.os_type
    sku_name = var.sku_name
  }
}
```

Create `terraform.tfvars` with real values:

```hcl
service_plan_name  = "asp-prod"
resource_group_name = "rg-apps-prod"
location           = "westeurope"
os_type            = "Linux"
sku_name           = "P1v3"
```

Use a quota-safe SKU for the simplest import parity when possible, for example:

```hcl
sku_name           = "S1"
```

Get current values with Azure CLI:

```bash
az appservice plan show -g <rg> -n <plan> --query '{name:name,location:location,kind:kind}' -o table
```

---

## 2) Add the import block(s)

Create `import.tf` with the App Service Plan import block:

```hcl
import {
  to = module.service_plan.azurerm_service_plan.service_plan
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Web/serverFarms/<plan>"
}
```

To get the exact ID:

```bash
az appservice plan show -g <rg> -n <plan> --query id -o tsv
```

### Optional diagnostic settings imports

If you configure `diagnostic_settings`, import matching diagnostic setting
instances after defining the same keys in module input:

```hcl
import {
  to = module.service_plan.azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings["asp-diag"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Web/serverFarms/<plan>|asp-diag"
}
```

Confirm existing diagnostic setting IDs with Azure CLI:

```bash
az monitor diagnostic-settings list --resource "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Web/serverFarms/<plan>" --query '[].id' -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected output in `plan`:
- one **import** action for the App Service Plan
- optional import actions for diagnostic settings
- no extra changes when module inputs match the existing resource

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg service_plan
```

If the plan is clean, you can remove `import.tf`.

---

## Common errors and fixes

- **Import does nothing**: import blocks execute on `terraform apply`, not `plan` alone.
- **Resource not found**: confirm the subscription and exact resource ID.
- **Plan shows changes after import**: module inputs do not match the existing App Service Plan configuration.
- **ASE-backed plans**: verify the imported SKU and `app_service_environment_id` align with the existing isolated plan.
