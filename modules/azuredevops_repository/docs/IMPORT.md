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

## Azure CLI setup (optional)

These commands use the Azure DevOps CLI extension to fetch IDs used in import blocks.

```bash
az extension add --name azure-devops
az devops configure --defaults organization=https://dev.azure.com/<ORG> project=<PROJECT>
az devops login --organization https://dev.azure.com/<ORG>
```

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
  #     ref_branch = "refs/heads/main"
  #     # policies defaults to {} and must not be null
  #     # policies = {}
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

Get repository ID with Azure CLI:

```bash
az repos show --repository <repo-name> --query id -o tsv
```

Get project ID with Azure CLI (module input):

```bash
az devops project show --project <PROJECT> --query id -o tsv
```

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

Module input requires exactly one of `ref_branch`, `ref_tag`, or `ref_commit_id`
for each branch. For existing branches, use `ref_branch = "refs/heads/<name>"`
to match the current ref.

Get branch refs with Azure CLI:

```bash
az repos ref list --repository <repo-name-or-id> --filter heads/ --query "[].name" -o tsv
```

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

List repository files (paths) with Azure CLI:

```bash
az devops invoke --http-method GET \
  --uri "https://dev.azure.com/<ORG>/<PROJECT>/_apis/git/repositories/<REPO_ID>/items?scopePath=/&recursionLevel=Full&api-version=7.1-preview.1" \
  --query "value[].path" -o tsv
```

File import IDs are provider-specific; you typically combine repository ID,
branch, and file path. Use the provider docs for the exact import ID format.

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

Get principal descriptors with Azure CLI:

```bash
az devops security group list --project <PROJECT> -o table
az devops user list --organization https://dev.azure.com/<ORG> -o table
```

Permission import IDs are provider-specific; you typically combine project ID,
repository ID, branch name, and principal descriptor. Use the provider docs for
the exact import ID format.

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

Get policy configuration IDs with Azure CLI:

```bash
az repos policy list --project <PROJECT> -o table
```

If your CLI does not support `az repos policy`, use the REST API via `az devops invoke`:

```bash
az devops invoke --http-method GET \
  --uri "https://dev.azure.com/<ORG>/<PROJECT>/_apis/policy/configurations?api-version=7.1-preview.1"
```

---

## 7) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, remove `import.tf`.
