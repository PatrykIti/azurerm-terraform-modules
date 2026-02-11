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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_redis_cache?ref=REDISv1.0.0"

  name                = var.redis_cache_name
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

  tags = {
    Environment = "Development"
    Example     = "Patch-Schedule"
  }
}
