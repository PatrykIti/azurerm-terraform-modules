# Import existing Azure DevOps Elastic Pool into the module

This guide explains how to import an existing Azure DevOps elastic pool into
`modules/azuredevops_elastic_pool` using Terraform import blocks.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the current elastic pool settings.

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

module "azuredevops_elastic_pool" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_elastic_pool?ref=ADOEPv1.0.0"

  name                   = "existing-elastic-pool"
  service_endpoint_id    = "service-endpoint-id"
  service_endpoint_scope = "project-id"
  azure_resource_id      = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Compute/virtualMachineScaleSets/<vmss>"
  desired_idle           = 1
  max_capacity           = 3
}
```

---

## 2) Import the elastic pool

Create `import.tf`:

```hcl
import {
  to = module.azuredevops_elastic_pool.azuredevops_elastic_pool.elastic_pool
  id = "<elastic_pool_id>"
}
```

Use the elastic pool ID from Azure DevOps.

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, remove `import.tf`.
