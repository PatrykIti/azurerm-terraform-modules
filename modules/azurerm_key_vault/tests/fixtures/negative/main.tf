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

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-negative"
  location = "northeurope"
}

module "key_vault" {
  source = "../../../"

  name                = "invalid_name"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = "00000000-0000-0000-0000-000000000000"

  soft_delete_retention_days = 3
}
