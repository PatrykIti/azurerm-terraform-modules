# Import existing Azure DevOps service principal entitlements into the module

This guide shows how to import existing Azure DevOps service principal entitlements into
`modules/azuredevops_service_principal_entitlement` using Terraform **import blocks**.

The flow is based on the **basic example** and keeps only the **module block**
in the configuration.

---

## Requirements

- Terraform **>= 1.12.2** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT
- Service principal `origin_id` values

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

module "azuredevops_service_principal_entitlement" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_service_principal_entitlement?ref=ADOSPEv1.0.0"

  origin_id            = "<service_principal_object_id>"
  account_license_type = "basic"
  licensing_source     = "account"
}
```

---

## 2) Add import blocks

Create `import.tf` and add import blocks for each resource.
Use the **module address** for the single entitlement resource.

```hcl
import {
  to = module.azuredevops_service_principal_entitlement.azuredevops_service_principal_entitlement.service_principal_entitlement
  id = "<service_principal_entitlement_id>"
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
terraform state list | rg azuredevops_service_principal_entitlement
```

When the plan is clean, remove `import.tf`.

---

## Common errors and fixes

- **Plan shows changes after import**: input values do not match existing settings. Align entitlements with current Azure DevOps state.
- **Import ID not found**: verify the descriptor or ID in the Azure DevOps UI or API.

## Helpful CLI commands (Azure AD / Azure DevOps)

```bash
# Login for az devops (uses PAT in AZURE_DEVOPS_EXT_PAT)
az devops login --organization "https://dev.azure.com/<org>"

# Get service principal object ID (origin_id) by appId/clientId
az ad sp show --id "<appId_or_clientId>" --query "id" -o tsv

# Optional: list SPs to confirm
az ad sp list --display-name "<name>" --query "[].{appId:appId,id:id}" -o table
```
