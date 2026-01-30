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
  name     = "rg-redis-negative-test"
  location = "westeurope"
}

# This should fail due to invalid name characters
module "redis_cache" {
  source = "../../.."

  name                = "redis invalid"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "Standard"
  family   = "C"
  capacity = 1

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
