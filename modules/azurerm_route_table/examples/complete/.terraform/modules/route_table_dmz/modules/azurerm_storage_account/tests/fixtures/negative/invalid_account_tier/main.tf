terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.43.0"
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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_route_table?ref=RTv1.0.3"

  name                = "devtmpcitiinvtier123"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  # Invalid: account tier must be Standard or Premium
  account_tier             = "Basic"
  account_replication_type = "LRS"
}