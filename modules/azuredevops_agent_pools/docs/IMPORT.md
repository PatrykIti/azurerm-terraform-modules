# Import existing Azure DevOps Agent Pools into the module

This guide explains how to import existing Azure DevOps agent pools, queues, and
elastic pools into `modules/azuredevops_agent_pools` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the **current**
agent pool settings.

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
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_agent_pools?ref=ADOAP1.0.0"

  name           = "existing-pool-name"
  auto_provision = false
  auto_update    = true
  pool_type      = "automation"

  # Optional: manage queues
  # agent_queues = [
  #   {
  #     key        = "default"
  #     project_id = "00000000-0000-0000-0000-000000000000"
  #   }
  # ]

  # Optional: manage elastic pool
  # elastic_pool = {
  #   name                   = "existing-elastic-pool"
  #   service_endpoint_id    = "service-endpoint-id"
  #   service_endpoint_scope = "project-id"
  #   azure_resource_id      = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Compute/virtualMachineScaleSets/<vmss>"
  #   desired_idle           = 1
  #   max_capacity           = 3
  # }
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

Use the **agent pool ID** from Azure DevOps (UI or API).

---

## 3) Import queues (optional)

If you manage queues, ensure each queue has a stable `key` and then add
import blocks like:

```hcl
import {
  to = module.azuredevops_agent_pools.azuredevops_agent_queue.agent_queue["default"]
  id = "<queue_import_id>"
}
```

The queue import ID format depends on the provider (commonly project and queue
IDs). Follow the Azure DevOps provider documentation for the exact format.

---

## 4) Import elastic pool (optional)

If you manage an elastic pool, add:

```hcl
import {
  to = module.azuredevops_agent_pools.azuredevops_elastic_pool.elastic_pool[0]
  id = "<elastic_pool_id>"
}
```

Use the elastic pool ID from Azure DevOps.

---

## 5) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, remove `import.tf`.

