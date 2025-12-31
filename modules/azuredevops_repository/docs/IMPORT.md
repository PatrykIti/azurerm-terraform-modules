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
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_repository?ref=ADOR1.0.0"

  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "existing-repo-name"

  # Optional: repository initialization
  # initialization = {
  #   init_type = "Clean"
  # }

  # Optional: manage branches/files/permissions/policies
  # branches = [
  #   {
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
  to = module.azuredevops_repository.azuredevops_git_repository.git_repository
  id = "<repository_id>"
}
```

Use the repository ID from Azure DevOps (UI or API).

---

## 3) Import branches (optional)

Branch resources are keyed by branch name:

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

File resources are keyed by `<file_path>:<branch>` where `<branch>` is `default`
when the branch is not set.

```hcl
import {
  to = module.azuredevops_repository.azuredevops_git_repository_file.git_repository_file["README.md:default"]
  id = "<file_import_id>"
}
```

---

## 5) Import permissions (optional)

Permission resources are keyed by `<branch_name>:<principal>` where
`branch_name` is `root` when not set.

```hcl
import {
  to = module.azuredevops_repository.azuredevops_git_permissions.git_permissions["root:group-1"]
  id = "<permissions_import_id>"
}
```

---

## 6) Import policies (optional)

Branch policies are keyed by:
- **single policies**: `<branch_name>`
- **list policies**: `<policy_name>` (must be unique across all branches for a given policy type)

Repository policies use `count` and are addressed with `[0]` when enabled.

Examples:

```hcl
import {
  to = module.azuredevops_repository.azuredevops_branch_policy_min_reviewers.branch_policy_min_reviewers["develop"]
  id = "<branch_policy_import_id>"
}

import {
  to = module.azuredevops_repository.azuredevops_branch_policy_build_validation.branch_policy_build_validation["ci"]
  id = "<branch_policy_import_id>"
}

import {
  to = module.azuredevops_repository.azuredevops_repository_policy_reserved_names.repository_policy_reserved_names[0]
  id = "<repository_policy_import_id>"
}
```

Repeat for other policy resources as needed.

---

## 7) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, remove `import.tf`.
