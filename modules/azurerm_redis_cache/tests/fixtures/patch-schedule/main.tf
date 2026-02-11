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

resource "azurerm_resource_group" "example" {
  name     = "rg-redis-patch-${var.random_suffix}"
  location = var.location
}

module "redis_cache" {
  source = "../../.."

  name                = "redispatch${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name = "Premium"
  family   = "P"
  capacity = 1

  patch_schedule = [
    {
      day_of_week    = "Saturday"
      start_hour_utc = 1
    }
  ]

  tags = var.tags
}
