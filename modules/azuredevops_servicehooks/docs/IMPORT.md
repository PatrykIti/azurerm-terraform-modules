# Import existing Azure DevOps Service Hooks into the module

This guide explains how to import existing webhook and storage queue service hooks
into `modules/azuredevops_servicehooks` using Terraform **import blocks**.

> Note: `azuredevops_servicehook_permissions` does **not** support import.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a module block and fill in **existing** settings.

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

module "azuredevops_servicehooks" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_servicehooks?ref=ADOSHv1.0.0"

  project_id = "00000000-0000-0000-0000-000000000000"

  webhook = {
    url      = "https://example.com/webhook"
    git_push = {}
  }

  storage_queue_hook = {
    account_name            = "existing-storage-account"
    account_key             = "existing-account-key"
    queue_name              = "existing-queue"
    visi_timeout            = 30
    run_state_changed_event = {}
  }
}
```

---

## 2) Import webhook service hooks

Create `import.tf` with an import block per webhook:

```hcl
import {
  to = module.azuredevops_servicehooks.azuredevops_servicehook_webhook_tfs.webhook[0]
  id = "<service_hook_id>"
}
```

Use the service hook **resource ID** from Azure DevOps (UI or API). Check the
Azure DevOps provider docs for the exact format.

---

## 3) Import storage queue service hooks

```hcl
import {
  to = module.azuredevops_servicehooks.azuredevops_servicehook_storage_queue_pipelines.storage_queue[0]
  id = "<service_hook_id>"
}
```

---

## 4) Permissions (not importable)

The permissions resource does not support import. Configure desired permissions
in Terraform and apply them going forward. Use `replace = false` to merge
permissions instead of overwriting them.

---

## 5) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, remove `import.tf`.
