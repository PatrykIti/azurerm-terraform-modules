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
  name     = var.resource_group_name
  location = var.location
}

module "redis_cache" {
  source = "../.."

  name                = var.redis_cache_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name = "Standard"
  family   = "C"
  capacity = 1

  redis_configuration = {
    maxmemory_policy                = "allkeys-lru"
    notify_keyspace_events          = "Ex"
    maxmemory_reserved              = 50
    maxmemory_delta                 = 50
    maxfragmentationmemory_reserved = 50
  }

  tags = {
    Environment = "Development"
    Example     = "Redis-Configuration"
  }
}
