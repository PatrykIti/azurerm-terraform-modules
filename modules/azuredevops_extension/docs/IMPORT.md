# Import existing Azure DevOps Extension into the module

This guide explains how to import an existing Azure DevOps Marketplace extension
into `modules/azuredevops_extension` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the **current**
extension settings.

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

module "azuredevops_extension" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_extension?ref=ADOEXv1.0.0"

  publisher_id = "existing-publisher-id"
  extension_id = "existing-extension-id"

  # Optional version pin
  # extension_version = "1.2.3"
}
```

---

## 2) Add the import block

Create `import.tf`:

```hcl
import {
  to = module.azuredevops_extension.azuredevops_extension.extension
  id = "publisher_id/extension_id"
}
```

Use `<publisher_id>/<extension_id>` for the import ID (confirm with the Azure DevOps
provider docs if your organization requires a different format).

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected output:
- one **import** action for `azuredevops_extension`
- no other changes

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg azuredevops_extension
```

When the plan is clean, you can remove `import.tf`.

---

## Importing multiple extensions (module-level for_each)

If you manage multiple extensions using module-level `for_each`, define stable
keys and add one import block per instance:

```hcl
module "azuredevops_extension" {
  source   = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_extension?ref=ADOEXv1.0.0"
  for_each = {
    "publisher/extension" = {
      publisher_id = "publisher"
      extension_id = "extension"
    }
  }

  publisher_id = each.value.publisher_id
  extension_id = each.value.extension_id
}

import {
  to = module.azuredevops_extension["publisher/extension"].azuredevops_extension.extension
  id = "publisher/extension"
}
```
