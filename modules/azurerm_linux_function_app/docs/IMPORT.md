# Import existing Linux Function App into the module (Terraform import blocks)

This guide shows how to import an existing Linux Function App into
`modules/azurerm_linux_function_app` using Terraform **import blocks**.

The flow is based on the **basic example** and keeps only the **module block**
in the configuration (no extra Terraform resources required).

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI logged in (`az login`)
- You know the **Function App name**, **resource group**, and **subscription**

---

## 1) Prepare a minimal config (module block only)

Create `main.tf` and keep just the **module block**. Replace values with your
existing Function App settings.

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

module "linux_function_app" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_linux_function_app?ref=LFUNCv1.0.0"

  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  service_plan_id = var.service_plan_id

  storage_configuration = {
    account_name       = var.storage_configuration.account_name
    account_access_key = var.storage_configuration.account_access_key
  }

  site_configuration = {
    application_stack = {
      node_version = "20"
    }
  }
}
```

Create `terraform.tfvars` with real values:

```hcl
function_app_name        = "func-prod"
resource_group_name      = "rg-apps-prod"
location                 = "westeurope"
service_plan_id          = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Web/serverFarms/<plan>"
storage_configuration = {
  account_name       = "stappsprod"
  account_access_key = "<secret>"
}
```

Get current values with Azure CLI:

```bash
az functionapp show -g <rg> -n <app> --query '{name:name,location:location}' -o table
```

---

## 2) Add the import block(s)

Create `import.tf` with the Function App import block:

```hcl
import {
  to = module.linux_function_app.azurerm_linux_function_app.linux_function_app
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Web/sites/<app>"
}
```

To get the **exact ID**:

```bash
az functionapp show -g <rg> -n <app> --query id -o tsv
```

### Optional imports

If you want the module to manage additional resources, import them after
providing matching inputs:

**Slots**
```hcl
import {
  to = module.linux_function_app.azurerm_linux_function_app_slot.linux_function_app_slot["blue"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Web/sites/<app>/slots/blue"
}
```

**Diagnostic settings**
```hcl
import {
  to = module.linux_function_app.azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting["diag"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Web/sites/<app>/providers/microsoft.insights/diagnosticSettings/diag"
}
```

---

## 3) Plan and apply

```bash
terraform init
terraform plan
```

Resolve any drift by aligning input values with the existing configuration.
