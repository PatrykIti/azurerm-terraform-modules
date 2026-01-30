# Import existing Data Collection Endpoint into the module (Terraform import blocks)

This guide shows how to import an existing Data Collection Endpoint into
`modules/azurerm_monitor_data_collection_endpoint` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI logged in (`az login`)
- You know the **endpoint name**, **resource group**, and **subscription**

---

## 1) Prepare a minimal config (module block only)

Create `main.tf` with only the **module block** and required providers.

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

module "monitor_data_collection_endpoint" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_monitor_data_collection_endpoint?ref=DCEv1.0.0"

  name                = var.endpoint_name
  resource_group_name = var.resource_group_name
  location            = var.location
}
```

Create `terraform.tfvars` with real values:

```hcl
endpoint_name       = "dce-prod"
resource_group_name = "rg-monitoring-prod"
location            = "westeurope"
```

---

## 2) Add the import block

Create `import.tf` with the endpoint import block:

```hcl
import {
  to = module.monitor_data_collection_endpoint.azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Insights/dataCollectionEndpoints/<endpoint>"
}
```

Get the **exact ID**:

```bash
az monitor data-collection endpoint show -g <rg> -n <endpoint> --query id -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected output in `plan`:
- one **import** action for the endpoint
- **no other changes** (unless inputs do not match existing settings)

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg monitor_data_collection_endpoint
```

If the plan is clean, you can **remove the import block** (`import.tf`).
