# Import existing Azure DevOps Agent Pools into the module

This guide explains how to import existing Azure DevOps agent pools into
`modules/azuredevops_agent_pools` using Terraform import blocks.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the current pool settings.

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

module "azuredevops_agent_pools" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_agent_pools?ref=ADOAPv1.0.0"

  name           = "existing-pool-name"
  auto_provision = false
  auto_update    = true
  pool_type      = "automation"
}
```

---

## 2) Import the agent pool

Create `import.tf`:

```hcl
import {
  to = module.azuredevops_agent_pools.azuredevops_agent_pool.agent_pool
  id = "<agent_pool_id>"
}
```

Use the agent pool ID from Azure DevOps (UI or API).

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, remove `import.tf`.
