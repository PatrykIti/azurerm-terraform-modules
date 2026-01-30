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
  name     = "rg-law-export-${var.random_suffix}"
  location = var.location
}

resource "azurerm_storage_account" "export" {
  name                     = "stlawexp${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "log_analytics_workspace" {
  source = "../../.."

  name                = "law-export-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  workspace = {
    sku               = "PerGB2018"
    retention_in_days = 30
  }

  features = {
    data_export_rules = [
      {
        name                    = "export-heartbeat"
        destination_resource_id = azurerm_storage_account.export.id
        table_names             = ["Heartbeat"]
        enabled                 = true
      }
    ]
  }

  tags = var.tags
}
