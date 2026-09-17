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

resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-neg-inv"
  location = "northeurope"
}

module "storage_account" {
  source = "../../../.."

  name                = "devtmpcitiinvrepl123"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  account_tier        = "Standard"
  # Invalid: replication type
  account_replication_type = "INVALID"
}