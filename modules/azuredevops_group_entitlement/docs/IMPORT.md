# Import existing Azure DevOps group entitlements into the module

This guide shows how to import an existing Azure DevOps group entitlement into
`modules/azuredevops_group_entitlement` using Terraform import blocks.

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

module "azuredevops_group_entitlement" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_group_entitlement?ref=ADOGEv1.0.0"

  group_entitlement = {
    key                  = "platform-group"
    display_name         = "ADO Platform Team"
    account_license_type = "basic"
    licensing_source     = "account"
  }
}
```

## 2) Add import block

```hcl
import {
  to = module.azuredevops_group_entitlement.azuredevops_group_entitlement.group_entitlement
  id = "<group_entitlement_id>"
}
```

## 3) Run import

```bash
terraform init
terraform plan
terraform apply
```

Expected result: resource is imported without extra changes when configuration matches existing state.
