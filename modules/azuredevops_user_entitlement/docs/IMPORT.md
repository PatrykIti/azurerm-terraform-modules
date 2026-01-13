# Import existing Azure DevOps user entitlements into the module

This guide shows how to import existing Azure DevOps user entitlements into
`modules/azuredevops_user_entitlement` using Terraform **import blocks**.

The flow is based on the **basic example** and keeps only the **module block**
in the configuration.

---

## Requirements

- Terraform **>= 1.12.2** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT
- User principal names or origin IDs

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

module "azuredevops_user_entitlement" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_user_entitlement?ref=ADOUv1.0.0"

  user_entitlement = {
    key                  = "user-entitlement"
    principal_name       = "<user_principal_name>"
    account_license_type = "basic"
    licensing_source     = "account"
  }
}
```

When iterating with `for_each` at the module level, keep module keys stable. The module derives its
`user_entitlement_key` from `key`, `principal_name`, or `origin_id`.

---

## 2) Add import blocks

Create `import.tf` and add import blocks for each resource.
Use the **module address**. If you use `for_each`, include the module instance key.

```hcl
import {
  to = module.azuredevops_user_entitlement.azuredevops_user_entitlement.user_entitlement
  id = "<user_entitlement_id>"
}
```

If you use `for_each` on the module:

```hcl
import {
  to = module.azuredevops_user_entitlement["user-entitlement"].azuredevops_user_entitlement.user_entitlement
  id = "<user_entitlement_id>"
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
terraform state list | rg azuredevops_user_entitlement
```

When the plan is clean, remove `import.tf`.

---

## Common errors and fixes

- **Plan shows changes after import**: input values do not match existing settings. Align entitlements with current Azure DevOps state.
- **Unknown key errors**: ensure the module instance key matches your `for_each` map keys.
- **Import ID not found**: verify the descriptor or ID in the Azure DevOps UI or API.
- **Duplicate key validation**: `for_each` keys must be unique when iterating.

## Helpful CLI commands (Azure AD / Azure DevOps)

```bash
# Login for az devops (uses PAT in AZURE_DEVOPS_EXT_PAT)
az devops login --organization "https://dev.azure.com/<org>"

# Get user object ID (origin_id) by UPN
az ad user show --id "user@example.com" --query "id" -o tsv

# Optional: check current ADO user ID
az devops user show --organization "https://dev.azure.com/<org>" --user "user@example.com" --query "id" -o tsv
```
