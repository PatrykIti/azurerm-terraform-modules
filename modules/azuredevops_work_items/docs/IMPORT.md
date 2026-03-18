# Import existing Azure DevOps Work Items into the module

This guide explains how to import an existing Azure DevOps work item into `modules/azuredevops_work_items` using Terraform import blocks.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the current work item settings.

```hcl
terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

module "azuredevops_work_items" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_work_items?ref=ADOWKv1.0.0"

  project_id = "00000000-0000-0000-0000-000000000000"
  title      = "existing-work-item-title"
  type       = "Task"
}
```

---

## 2) Import the work item

Create `import.tf`:

```hcl
import {
  to = module.azuredevops_work_items.azuredevops_workitem.work_item
  id = "<project_id>/<work_item_id>"
}
```

Use the work item ID from Azure DevOps (UI or REST API). Refer to the Azure DevOps provider documentation for the exact import ID format.

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, remove `import.tf`.
