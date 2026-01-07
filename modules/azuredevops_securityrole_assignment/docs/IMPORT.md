# Import existing Azure DevOps security role assignments into the module

This guide shows how to import existing Azure DevOps security role assignments into
`modules/azuredevops_securityrole_assignment` using Terraform **import blocks**.

The flow is based on the **basic example** and keeps only the **module block**
in the configuration.

---

## Requirements

- Terraform **>= 1.12.2** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT
- Role assignment IDs and target identity IDs

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with existing values.

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

module "azuredevops_securityrole_assignment" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_securityrole_assignment?ref=ADOSRAv1.0.0"

  securityrole_assignments = [
    {
      key         = "project-reader"
      scope       = "project"
      resource_id = "<project_id>"
      role_name   = "Reader"
      identity_id = "<group_or_identity_id>"
    }
  ]
}
```

When using list inputs, derived keys default to `key` or a combination of scope/resource/role/identity. Set an explicit
`key` to keep a stable import address.

---

## 2) Add import blocks

Create `import.tf` and add import blocks for each resource.
Use the **module address** with the stable key that matches your inputs.

```hcl
import {
  to = module.azuredevops_securityrole_assignment.azuredevops_securityrole_assignment.securityrole_assignment["project-reader"]
  id = "<security_role_assignment_id>"
}
```

Refer to the Azure DevOps provider documentation for the exact import ID format.

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected output:
- one **import** action for each resource
- no additional changes

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg azuredevops_securityrole_assignment
```

When the plan is clean, remove `import.tf`.

---

## Common errors and fixes

- **Plan shows changes after import**: input values do not match existing settings. Align assignments with current Azure DevOps state.
- **Unknown key errors**: ensure the derived keys match your list inputs or set explicit `key` values.
- **Import ID not found**: verify the ID in the Azure DevOps UI or API.
- **Duplicate key validation**: list inputs must have unique derived keys or explicit `key` values.

## Helpful CLI commands (Azure DevOps / Azure AD)

```bash
# Login for az devops (uses PAT in AZURE_DEVOPS_EXT_PAT)
az devops login --organization "https://dev.azure.com/<org>"

# Find identity descriptor/originId for a group (use as identity_id)
az devops security group list \
  --organization "https://dev.azure.com/<org>" \
  --query "graphGroups[?displayName=='ADO Platform Team'].{descriptor:descriptor,originId:originId}" -o table

# Find identity ID for a user (use as identity_id)
az devops user show --organization "https://dev.azure.com/<org>" --user "user@example.com" --query "id" -o tsv
```
