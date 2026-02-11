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
  name     = "rg-redis-linked-${var.random_suffix}"
  location = var.location
}

module "redis_secondary" {
  source = "../../.."

  name                = "redissecondary${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = var.secondary_location

  sku_name = "Premium"
  family   = "P"
  capacity = 1

  tags = var.tags
}

module "redis_primary" {
  source = "../../.."

  name                = "redisprimary${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = var.location

  sku_name = "Premium"
  family   = "P"
  capacity = 1

  linked_servers = [
    {
      name                        = "secondary-link"
      linked_redis_cache_id       = module.redis_secondary.id
      linked_redis_cache_location = module.redis_secondary.location
      server_role                 = "Secondary"
    }
  ]

  tags = var.tags
}
