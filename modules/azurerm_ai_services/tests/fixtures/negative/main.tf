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
  name     = "rg-ai-services-negative-test"
  location = "West Europe"
}

# This should fail due to invalid name format
module "ai_services" {
  source = "../../../"

  name                = "invalid_name!"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "S0"

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
