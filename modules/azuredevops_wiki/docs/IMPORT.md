# Import existing Azure DevOps wikis into the module

This guide explains how to import existing Azure DevOps wikis and pages into
`modules/azuredevops_wiki` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the **current**
wiki settings.

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

module "azuredevops_wiki" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_wiki?ref=ADOWIv1.0.0"

  project_id = "00000000-0000-0000-0000-000000000000"

  wikis = {
    project = {
      name = "Project Wiki"
      type = "projectWiki"
    }
  }

  # Optional: manage wiki pages
  # wiki_pages = [
  #   {
  #     wiki_key = "project"
  #     path     = "/Home"
  #     content  = "Welcome to the project wiki."
  #   }
  # ]
}
```

---

## 2) Import the wiki

Create `import.tf`:

```hcl
import {
  to = module.azuredevops_wiki.azuredevops_wiki.wiki["project"]
  id = "<wiki_id>"
}
```

Use the wiki ID from Azure DevOps (UI or API).

---

## 3) Import wiki pages (optional)

When managing pages, import each page by its index (based on `wiki_pages` order).

```hcl
import {
  to = module.azuredevops_wiki.azuredevops_wiki_page.wiki_page[0]
  id = "<wiki_page_import_id>"
}
```

The page import ID format is provider-specific. Refer to the Azure DevOps provider
documentation for the exact format.

---

## 4) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, remove `import.tf`.
