# Import existing Storage Account into the module (Terraform import blocks)

This guide shows how to import an existing Azure Storage Account into
`modules/azurerm_storage_account` using Terraform **import blocks**.

It is based on the **basic example** and keeps only the **module block** in the config.

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI logged in (`az login`)
- You know the **storage account name**, **resource group**, and **subscription**

---

## 1) Prepare a minimal config (module block only)

Create `main.tf` and copy the module block from the basic example.
Replace values with your **existing** storage account settings.

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

module "storage_account" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.2.2"

  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind

  # Optional: match your existing security posture
  security_settings = var.security_settings

  tags = var.tags
}
```

Create `terraform.tfvars` with **real values** from your storage account:

```hcl
storage_account_name    = "stprod001"
resource_group_name     = "rg-storage-prod"
location                = "westeurope"
account_tier            = "Standard"
account_replication_type = "ZRS"
account_kind            = "StorageV2"

security_settings = {
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = true
  allow_nested_items_to_be_public = false
}

tags = {
  Environment = "Prod"
  ManagedBy   = "Terraform"
}
```

### Where to get values (Azure CLI)

```bash
az storage account show \
  --name <storage_account_name> \
  --resource-group <resource_group_name> \
  --query '{name:name,location:location,kind:kind,sku:sku.name}' -o table
```

---

## 2) Add the import block

Create `import.tf` with the module import block:

```hcl
import {
  to = module.storage_account.azurerm_storage_account.storage_account
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<storage_account_name>"
}
```

To get the exact ID:

```bash
az storage account show -g <rg> -n <name> --query id -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected output:
- one **import** action for the storage account
- **no other changes**

If you see changes, align your inputs and re-run `plan`.

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg storage_account
```

If the plan is clean, you can **remove the import block** (`import.tf`).

---

## Importing optional resources (if used)

If your module config enables additional resources, add import blocks for them too:

```hcl
# Static website (when enabled)
import {
  to = module.storage_account.azurerm_storage_account_static_website.static_website[0]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<name>"
}

# Queue properties (when logging enabled)
import {
  to = module.storage_account.azurerm_storage_account_queue_properties.queue_properties[0]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<name>"
}
```

For each container/queue/table/share managed by the module, import the specific ID:

```hcl
import {
  to = module.storage_account.azurerm_storage_container.storage_container["logs"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<name>/blobServices/default/containers/logs"
}
```

---

## Common errors and fixes

- **Import does nothing**: import blocks run only on `terraform apply`.
- **Resource not found**: wrong ID or subscription. Check `az account show`.
- **Plan shows changes**: inputs do not match existing settings. Re-check:
  - `account_kind`, `account_tier`, `account_replication_type`
  - `security_settings` (HTTPS/TLS/shared keys)
  - `network_rules`
- **Permission errors**: you need at least **Contributor** on the resource group.

---

## Notes

- This guide covers only the **storage account** resource. Optional resources must be imported explicitly.
- Diagnostic settings are managed via the `diagnostic_settings` input; add import blocks for those if already configured.
