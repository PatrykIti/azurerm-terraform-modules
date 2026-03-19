# Import existing Managed Redis into the module (Terraform import blocks)

This guide shows how to import an existing Azure Managed Redis deployment into
`modules/azurerm_managed_redis` using Terraform import blocks.

---

## Requirements

- Terraform `>= 1.5` for import blocks and module requirement `>= 1.12.2`
- Azure CLI logged in (`az login`)
- Existing Managed Redis name, resource group, and subscription ID

---

## 1) Prepare a minimal config

Create a `main.tf` with only the module block and fill in the current values of
the existing Managed Redis deployment.

```hcl
terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "managed_redis" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_managed_redis?ref=AMRv1.0.0"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  managed_redis = {
    sku_name = var.sku_name
  }
}
```

Example `terraform.tfvars`:

```hcl
name                = "managed-redis-prod"
resource_group_name = "rg-cache-prod"
location            = "westeurope"
sku_name            = "Balanced_B3"
```

Use Azure CLI to inspect the existing resource:

```bash
az resource show \
  --resource-group <rg> \
  --name <managed-redis-name> \
  --resource-type "Microsoft.Cache/redisEnterprise" \
  --query "{name:name,location:location,id:id}" \
  -o json
```

---

## 2) Add the import block

Create `import.tf` with the Managed Redis import block:

```hcl
import {
  to = module.managed_redis.azurerm_managed_redis.managed_redis
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Cache/redisEnterprise/<managed-redis-name>"
}
```

To fetch the exact resource ID:

```bash
az resource show \
  --resource-group <rg> \
  --name <managed-redis-name> \
  --resource-type "Microsoft.Cache/redisEnterprise" \
  --query id \
  -o tsv
```

### Optional import: geo-replication membership

If this module is also meant to manage geo-replication membership, define the
matching `geo_replication` input and add:

```hcl
import {
  to = module.managed_redis.azurerm_managed_redis_geo_replication.geo_replication[0]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Cache/redisEnterprise/<managed-redis-name>"
}
```

### Optional import: diagnostic settings

After defining matching `monitoring` entries:

**Connection logs**
```hcl
import {
  to = module.managed_redis.azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings_logs["diag"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Cache/redisEnterprise/<managed-redis-name>/databases/default|diag"
}
```

**Platform metrics**
```hcl
import {
  to = module.managed_redis.azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings_metrics["diag"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Cache/redisEnterprise/<managed-redis-name>|diag"
}
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected result:

- one import action for the Managed Redis instance
- optional imports for geo-replication membership or diagnostic settings
- no unexpected drift once the module inputs match the existing deployment

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg managed_redis
```

If the plan is clean, remove `import.tf`.

---

## Common errors and fixes

- **Plan shows changes after import**: The module inputs do not match the existing Managed Redis configuration.
- **Geo-replication import fails**: Ensure the deployment already has a matching `geo_replication_group_name` and linked peers.
- **CMK drift after import**: The user-assigned identity and Key Vault permissions must match what Azure is using.
