# Import existing Data Collection Rule into the module (Terraform import blocks)

This guide shows how to import an existing Data Collection Rule into
`modules/azurerm_monitor_data_collection_rule` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI logged in (`az login`)
- You know the **rule name**, **resource group**, and **subscription**

---

## 1) Prepare a minimal config (module block only)

Create `main.tf` with only the **module block** and required providers.

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

module "monitor_data_collection_rule" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_monitor_data_collection_rule?ref=DCRv1.0.0"

  name                = var.rule_name
  resource_group_name = var.resource_group_name
  location            = var.location

  destinations = var.destinations
  data_flows   = var.data_flows
}
```

Create `terraform.tfvars` with real values (these must match the existing rule):

```hcl
rule_name           = "dcr-prod"
resource_group_name = "rg-monitoring-prod"
location            = "westeurope"

# Example destinations + data flows (update to match your rule)
destinations = {
  log_analytics = [
    {
      name                  = "log-analytics"
      workspace_resource_id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<workspace>"
    }
  ]
}

data_flows = [
  {
    streams      = ["Microsoft-Perf"]
    destinations = ["log-analytics"]
  }
]
```

---

## 2) Add the import block

Create `import.tf` with the rule import block:

```hcl
import {
  to = module.monitor_data_collection_rule.azurerm_monitor_data_collection_rule.monitor_data_collection_rule
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Insights/dataCollectionRules/<rule>"
}
```

Get the **exact ID**:

```bash
az monitor data-collection rule show -g <rg> -n <rule> --query id -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected output in `plan`:
- one **import** action for the rule
- **no other changes** (unless inputs do not match existing settings)

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg monitor_data_collection_rule
```

If the plan is clean, you can **remove the import block** (`import.tf`).
