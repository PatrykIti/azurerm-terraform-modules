# Import existing Azure DevOps group resources into the module

This guide shows how to import existing Azure DevOps group resources into
`modules/azuredevops_group` using Terraform import blocks.

## 1) Minimal module configuration

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

module "azuredevops_group" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_group?ref=ADOGv1.0.0"

  group_display_name = "ADO Platform Team"
  group_description  = "Platform engineering group"

  group_memberships = [
    {
      key                = "platform-membership"
      member_descriptors = ["<member_descriptor>"]
      mode               = "add"
    }
  ]
}
```

## 2) Add import blocks

```hcl
import {
  to = module.azuredevops_group.azuredevops_group.group
  id = "<group_descriptor_or_id>"
}

import {
  to = module.azuredevops_group.azuredevops_group_membership.group_membership["platform-membership"]
  id = "<group_membership_id>"
}
```

## 3) Run import

```bash
terraform init
terraform plan
terraform apply
```

Expected output:
- one import action for each resource
- no additional changes when configuration matches existing state

> Group entitlement import is covered by `modules/azuredevops_group_entitlement/docs/IMPORT.md`.
