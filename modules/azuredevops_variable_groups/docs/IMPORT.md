# Import existing Azure DevOps Variable Groups into the module

This guide explains how to import existing Azure DevOps variable groups into
`modules/azuredevops_variable_groups` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the **current**
variable group settings.

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

module "azuredevops_variable_groups" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_variable_groups?ref=ADOVGv1.0.0"

  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "existing-variable-group"

  variables = [
    {
      name  = "environment"
      value = "prod"
    }
  ]

  # Optional: key_vault = { ... }
  # Optional: variable_group_permissions = [ ... ]
  # Optional: library_permissions = [ ... ]
}
```

---

## 2) Import the variable group

Create `import.tf`:

```hcl
import {
  to = module.azuredevops_variable_groups.azuredevops_variable_group.variable_group
  id = "<variable_group_id>"
}
```

Use the **variable group ID** from Azure DevOps (UI or API).

---

## 3) Import permissions (optional)

If you manage permissions, ensure each entry has a stable `key` (or a unique
principal) so the import address is deterministic. When `variable_group_id` is
omitted, the module variable group ID is used.

```hcl
import {
  to = module.azuredevops_variable_groups.azuredevops_variable_group_permissions.variable_group_permissions["readers"]
  id = "<variable_group_permissions_id>"
}

import {
  to = module.azuredevops_variable_groups.azuredevops_library_permissions.library_permissions["readers"]
  id = "<library_permissions_id>"
}
```

Refer to the Azure DevOps provider documentation for the exact import ID format
for permissions resources.

---

## 4) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, proceed to verification.

---

## 5) Verify and clean up

```bash
terraform plan
terraform state list | rg azuredevops_variable_group
```

When the state is correct, remove `import.tf`.
