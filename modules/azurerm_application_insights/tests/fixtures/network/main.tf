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
  name     = "rg-appins-extra-${var.random_suffix}"
  location = var.location
}

module "application_insights" {
  source = "../../.."

  name                = "appi-extra-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  application_type    = "web"

  tags = {
    Environment = "Test"
    Scenario    = "Extra"
  }
}
