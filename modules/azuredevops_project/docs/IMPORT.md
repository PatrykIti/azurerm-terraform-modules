# Import existing Azure DevOps Project into the module

This guide explains how to import an existing Azure DevOps project into
`modules/azuredevops_project` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the **current**
project settings.

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

module "azuredevops_project" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_project?ref=ADOP1.0.0"

  name               = "existing-project-name"
  description        = "Existing project managed by Terraform"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  # Optional: manage feature flags if you want Terraform to own them
  # features = {
  #   boards       = "enabled"
  #   repositories = "enabled"
  # }
}
```

---

## 2) Add the import block

Create `import.tf`:

```hcl
import {
  to = module.azuredevops_project.azuredevops_project.project
  id = "existing-project-name"
}
```

You can use either the **project name** or **project ID (GUID)** as the import ID.

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected output:
- one **import** action for `azuredevops_project`
- no other changes

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg azuredevops_project
```

When the plan is clean, you can remove `import.tf`.

---

## Additional resources

- Project permissions are managed in the separate `azuredevops_project_permissions` module.
- `azuredevops_project_permissions` **does not support import** (provider limitation).
- For `azuredevops_project_pipeline_settings`, `azuredevops_project_tags`, and
  `azuredevops_dashboard`, verify import support in the provider docs. If import
  is not available, configure them in the module and let Terraform create them.

---

## Common errors and fixes

- **Plan shows changes after import**: Inputs do not match existing settings.
  Re-check `visibility`, `version_control`, `work_item_template`, and `features`.
- **Features drift**: If you set `features`, ensure it matches the current
  feature flags in the project, or leave it unset to avoid conflicts.
