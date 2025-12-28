# Import existing Azure DevOps Work Items into the module

This guide explains how to import existing Azure DevOps work items, query
folders, queries, and permissions into `modules/azuredevops_work_items` using
Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the **current**
resource settings. Use stable `key` values for list entries you plan to import.

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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_work_items?ref=ADOWKv1.0.0"

  project_id = "00000000-0000-0000-0000-000000000000"

  title = "Existing Work Item"
  type  = "Issue"

  query_folders = [
    {
      key  = "team"
      name = "Team"
      area = "Shared Queries"
    }
  ]

  queries = [
    {
      key        = "active-issues"
      name       = "Active Issues"
      parent_key = "team"
      wiql       = "SELECT [System.Id] FROM WorkItems"
    }
  ]

  query_permissions = [
    {
      key       = "active-issues-readers"
      query_key = "active-issues"
      principal = "descriptor-0001"
      permissions = {
        Read = "Allow"
      }
    }
  ]
}
```

---

## 2) Import work item

Create `import.tf`:

```hcl
import {
  to = module.azuredevops_work_items.azuredevops_workitem.work_item
  id = "<work_item_id>"
}
```

Use the **work item ID** from Azure DevOps (numeric ID).

---

## 3) Import query folders and queries

```hcl
import {
  to = module.azuredevops_work_items.azuredevops_workitemquery_folder.query_folder["team"]
  id = "<query_folder_id>"
}

import {
  to = module.azuredevops_work_items.azuredevops_workitemquery.query["active-issues"]
  id = "<query_id>"
}
```

Use the folder/query IDs as defined by the Azure DevOps provider. Follow the
provider docs for exact import ID formats.

---

## 4) Import query permissions (optional)

```hcl
import {
  to = module.azuredevops_work_items.azuredevops_workitemquery_permissions.query_permissions["active-issues-readers"]
  id = "<query_permission_id>"
}
```

Query permission import IDs are provider-specific. Check the Azure DevOps
provider documentation for the expected format.

---

## 5) Import area/iteration/tagging permissions (optional)

```hcl
import {
  to = module.azuredevops_work_items.azuredevops_area_permissions.area_permissions["area-root"]
  id = "<area_permission_id>"
}

import {
  to = module.azuredevops_work_items.azuredevops_iteration_permissions.iteration_permissions["iteration-root"]
  id = "<iteration_permission_id>"
}

import {
  to = module.azuredevops_work_items.azuredevops_tagging_permissions.tagging_permissions["tagging-root"]
  id = "<tagging_permission_id>"
}
```

Permission import IDs depend on the Azure DevOps provider. Validate the ID
formats in the provider documentation.

---

## 6) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, remove `import.tf`.
