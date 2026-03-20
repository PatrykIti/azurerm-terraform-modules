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
  name     = "rg-amr-negative"
  location = "westeurope"
}

module "managed_redis" {
  source = "../../../"

  name                = "amrnegativeexample"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  managed_redis = {
    sku_name              = "Balanced_B3"
    public_network_access = "NotValid"
  }
}
