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
  name     = "rg-asp-negative-test"
  location = "westeurope"
}

# This should fail due to unsupported SKU for zone balancing.
module "service_plan" {
  source = "../../../"

  name                = "asp-negative-test"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  service_plan = {
    os_type                = "Windows"
    sku_name               = "B1"
    worker_count           = 1
    zone_balancing_enabled = true
  }

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
