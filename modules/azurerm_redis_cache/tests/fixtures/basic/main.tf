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
  name     = "rg-redis-basic-${var.random_suffix}"
  location = var.location
}

module "redis_cache" {
  source = "../../.."

  name                = "redisbasic${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name = "Standard"
  family   = "C"
  capacity = 1

  tags = var.tags
}
