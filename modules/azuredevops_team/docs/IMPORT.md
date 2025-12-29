# Import existing Azure DevOps Teams into the module

This guide explains how to import existing Azure DevOps teams, memberships, and
administrators into `modules/azuredevops_team` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the **current**
team settings.

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

module "azuredevops_team" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_team?ref=ADOT1.0.0"

  project_id  = "00000000-0000-0000-0000-000000000000"
  name        = "existing-team-name"
  description = "Existing team managed by Terraform"

  # Optional: manage team members
  # team_members = [
  #   {
  #     key                = "core-members"
  #     member_descriptors = ["vssgp.Uy0xLTktMTIzNDU2"]
  #   }
  # ]

  # Optional: manage team administrators
  # team_administrators = [
  #   {
  #     key               = "core-admins"
  #     admin_descriptors = ["vssgp.Uy0xLTktMTIzNDU2"]
  #     mode              = "overwrite"
  #   }
  # ]
}
```

---

## 2) Import the team

Create `import.tf`:

```hcl
import {
  to = module.azuredevops_team.azuredevops_team.team
  id = "<team_id>"
}
```

Use the **team ID** from Azure DevOps (UI or API).

---

## 3) Import team members (optional)

If you manage team members, ensure each membership has a stable `key` and add:

```hcl
import {
  to = module.azuredevops_team.azuredevops_team_members.team_members["core-members"]
  id = "<team_membership_import_id>"
}
```

The membership import ID format depends on the provider. Follow the Azure DevOps
provider documentation for the exact format.

---

## 4) Import team administrators (optional)

If you manage team administrators, ensure each entry has a stable `key` and add:

```hcl
import {
  to = module.azuredevops_team.azuredevops_team_administrators.team_administrators["core-admins"]
  id = "<team_admin_import_id>"
}
```

The administrator import ID format depends on the provider. Follow the Azure
DevOps provider documentation for the exact format.

---

## 5) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, remove `import.tf`.
