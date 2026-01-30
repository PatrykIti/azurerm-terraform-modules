# Negative test cases - should fail validation
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
  name     = "rg-ehns-negative-test"
  location = "West Europe"
}

# This should fail due to invalid name
module "eventhub_namespace" {
  source = "../../../"

  name                = "1invalid"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku = "Standard"

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
