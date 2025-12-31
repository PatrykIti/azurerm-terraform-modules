# Import existing Azure DevOps identities into the module

This guide shows how to import existing Azure DevOps identity resources into
`modules/azuredevops_identity` using Terraform **import blocks**.

The flow is based on the **basic example** and keeps only the **module block**
in the configuration.

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT
- Identifiers for the resources you want to import (descriptors, IDs)

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

module "azuredevops_identity" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_identity?ref=ADOI1.0.0"

  group_display_name = "ADO Platform Team"
  group_description  = "Platform engineering group"

  group_memberships = [
    {
      key                = "platform-membership"
      member_descriptors = ["<member_descriptor>"]
    }
  ]
}
```

If you use list resources without an explicit `key`, note the derived keys:

- Group memberships: `key` or `group_descriptor`
- Group entitlements: `key` or `display_name` or `origin_id`
- User entitlements: `key` or `principal_name` or `origin_id`
- Service principal entitlements: `key` or `origin_id`
- Security role assignments: `key` or `identity_id` or `scope/resource_id/role_name`

When targeting the module-managed group without `group_descriptor`, set `key`
explicitly to keep a stable import address.

---

## 2) Add import blocks

Create `import.tf` and add import blocks for each resource.
Use the **module address** with the stable key that matches your inputs.

```hcl
import {
  to = module.azuredevops_identity.azuredevops_group.group[0]
  id = "<group_descriptor_or_id>"
}

import {
  to = module.azuredevops_identity.azuredevops_group_membership.group_membership["platform-membership"]
  id = "<group_descriptor_or_membership_id>"
}

import {
  to = module.azuredevops_identity.azuredevops_group_entitlement.group_entitlement["group-entitlement"]
  id = "<group_entitlement_id>"
}

import {
  to = module.azuredevops_identity.azuredevops_user_entitlement.user_entitlement["user-entitlement"]
  id = "<user_entitlement_id>"
}

import {
  to = module.azuredevops_identity.azuredevops_service_principal_entitlement.service_principal_entitlement["service-principal-entitlement"]
  id = "<service_principal_entitlement_id>"
}

import {
  to = module.azuredevops_identity.azuredevops_securityrole_assignment.securityrole_assignment["platform-reader"]
  id = "<security_role_assignment_id>"
}
```

Refer to the Azure DevOps provider documentation for the exact import ID formats
for each resource type.

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
terraform state list | rg azuredevops_identity
```

When the plan is clean, remove `import.tf`.

---

## Common errors and fixes

- **Plan shows changes after import**: input values do not match existing settings.
  Align group settings, entitlements, and role assignments with current Azure DevOps state.
- **Unknown key errors**: ensure the derived keys match your list inputs or set explicit `key` values.
- **Missing group_descriptor**: provide `group_descriptor` when the module group is not configured.
- **Import ID not found**: verify the descriptor or ID in the Azure DevOps UI or API.
- **Duplicate key validation**: list inputs must have unique derived keys or explicit `key` values.
