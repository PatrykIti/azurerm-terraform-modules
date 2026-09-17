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
  name     = "rg-law-negative-test"
  location = "westeurope"
}

# This should fail due to invalid name (spaces).
module "log_analytics_workspace" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv3.0.0"

  name                = "invalid name with spaces"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
