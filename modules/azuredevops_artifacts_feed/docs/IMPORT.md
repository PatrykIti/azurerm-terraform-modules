# Import existing Azure DevOps Artifacts Feeds into the module

This guide explains how to import existing Azure DevOps artifacts feeds,
feed permissions, and retention policies into `modules/azuredevops_artifacts_feed`
using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the **current**
feed settings.

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

module "azuredevops_artifacts_feed" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_artifacts_feed?ref=ADOAFv1.0.0"

  name       = "existing-feed-name"
  project_id = "00000000-0000-0000-0000-000000000000"

  # Optional: manage feed permissions
  # feed_permissions = [
  #   {
  #     key                 = "project-reader"
  #     identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
  #     role                = "reader"
  #   }
  # ]

  # Optional: manage retention policies
  # feed_retention_policies = [
  #   {
  #     key                                       = "project-retention"
  #     count_limit                               = 10
  #     days_to_keep_recently_downloaded_packages = 30
  #   }
  # ]
}
```

---

## 2) Import the feed

Create `import.tf`:

```hcl
import {
  to = module.azuredevops_artifacts_feed.azuredevops_feed.feed[0]
  id = "<feed_id>"
}
```

Use the **feed ID** from Azure DevOps (UI or API).

---

## 3) Import feed permissions (optional)

Ensure each permission entry has a stable `key` and then add import blocks like:

```hcl
import {
  to = module.azuredevops_artifacts_feed.azuredevops_feed_permission.feed_permission["project-reader"]
  id = "<permission_import_id>"
}
```

The permission import ID format depends on the provider. Follow the Azure DevOps
provider documentation for the exact format.

---

## 4) Import retention policies (optional)

If you manage retention policies, add:

```hcl
import {
  to = module.azuredevops_artifacts_feed.azuredevops_feed_retention_policy.feed_retention_policy["project-retention"]
  id = "<retention_policy_import_id>"
}
```

Use the retention policy ID format from the provider documentation.

---

## 5) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, remove `import.tf`.
