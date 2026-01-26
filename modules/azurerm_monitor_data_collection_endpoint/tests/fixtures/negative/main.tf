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
  name     = "rg-dce-negative-${var.random_suffix}"
  location = var.location
}

# Invalid name (underscore is not allowed by module validation)
module "monitor_data_collection_endpoint" {
  source = "../../../"

  name                = "dce_invalid_${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
