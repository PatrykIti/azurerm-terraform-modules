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
  name     = "rg-appins-negative-test"
  location = "westeurope"
}

# This should fail due to invalid name
module "application_insights" {
  source = "../../.."

  name                = "invalid name with spaces"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  application_type    = "web"

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
