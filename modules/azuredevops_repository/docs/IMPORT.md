# Import existing Azure DevOps repositories into the module

This guide explains how to import existing Azure DevOps Git repositories, branches,
files, permissions, and policies into `modules/azuredevops_repository` using Terraform
**import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the **current**
repository settings.

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

module "azuredevops_repository" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_repository?ref=ADORv1.0.0"

  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "existing-repo-name"

  initialization = {
    init_type = "Clean"
  }

  # Optional: manage branches/files/permissions/policies
  # branches = [
  #   {
  #     key  = "develop"
  #     name = "develop"
  #   }
  # ]
}
```

---

## 2) Import the repository

Create `import.tf`:

```hcl
import {
  to = module.azuredevops_repository.azuredevops_git_repository.git_repository[0]
  id = "<repository_id>"
}
```

Use the repository ID from Azure DevOps (UI or API).

---

## 3) Import branches (optional)

If you manage branches, ensure each branch has a stable `key` and then add:

```hcl
import {
  to = module.azuredevops_repository.azuredevops_git_repository_branch.git_repository_branch["develop"]
  id = "<branch_import_id>"
}
```

The branch import ID format depends on the provider (commonly a repository ID
and branch name). Follow the Azure DevOps provider documentation for the exact
format.

---

## 4) Import files (optional)

If you manage repository files, use stable keys:

```hcl
import {
  to = module.azuredevops_repository.azuredevops_git_repository_file.git_repository_file["readme"]
  id = "<file_import_id>"
}
```

---

## 5) Import permissions (optional)

```hcl
import {
  to = module.azuredevops_repository.azuredevops_git_permissions.git_permissions["main-contributors"]
  id = "<permissions_import_id>"
}
```

---

## 6) Import policies (optional)

```hcl
import {
  to = module.azuredevops_repository.azuredevops_branch_policy_min_reviewers.branch_policy_min_reviewers["min-reviewers"]
  id = "<branch_policy_import_id>"
}

import {
  to = module.azuredevops_repository.azuredevops_repository_policy_reserved_names.repository_policy_reserved_names["reserved-names"]
  id = "<repository_policy_import_id>"
}
```

Repeat for other branch/repository policy resources as needed.

---

## 7) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, remove `import.tf`.
