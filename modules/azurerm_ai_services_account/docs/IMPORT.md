# Import existing AI Services Account (Terraform import blocks)

This guide explains how to import an existing Azure AI Services Account into
`modules/azurerm_ai_services_account` using Terraform **import blocks**.

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI logged in (`az login`)
- The AI Services Account **name**, **resource group**, and **subscription**

## 1) Minimal configuration

Create `main.tf` and include only the module block (adjust values to match your account):

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

module "ai_services_account" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_ai_services_account?ref=AISAv1.0.0"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name
}
```

## 2) Add the import block

Create `import.tf`:

```hcl
import {
  to = module.ai_services_account.azurerm_ai_services.ai_services
  id = "<resource-id>"
}
```

Fetch the resource ID using Azure CLI:

```bash
az cognitiveservices account show \
  --name <account-name> \
  --resource-group <resource-group> \
  --query id -o tsv
```

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

The plan should show **only** the import action. If changes appear, update your
inputs to reflect the existing account configuration.
