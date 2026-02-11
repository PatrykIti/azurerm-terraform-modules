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
  location = var.primary_location
}

module "redis_secondary" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_redis_cache?ref=REDISv1.0.0"

  name                = var.secondary_cache_name
  resource_group_name = azurerm_resource_group.example.name
  location            = var.secondary_location

  sku_name = "Premium"
  family   = "P"
  capacity = 1

  tags = {
    Environment = "Development"
    Example     = "Linked-Server-Secondary"
  }
}

module "redis_primary" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_redis_cache?ref=REDISv1.0.0"

  name                = var.primary_cache_name
  resource_group_name = azurerm_resource_group.example.name
  location            = var.primary_location

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

  tags = {
    Environment = "Development"
    Example     = "Linked-Server-Primary"
  }
}
