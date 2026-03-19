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
  name     = "rg-managed-redis-geo-example"
  location = var.primary_location
}

module "managed_redis_secondary" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_managed_redis?ref=AMRv1.0.0"

  name                = "managed-redis-secondary-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = var.secondary_location

  managed_redis = {
    sku_name = "Balanced_B3"
  }

  default_database = {
    geo_replication_group_name = var.geo_replication_group_name
  }

  tags = {
    Environment = "Development"
    Example     = "GeoReplicationSecondary"
  }
}

module "managed_redis_primary" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_managed_redis?ref=AMRv1.0.0"

  name                = "managed-redis-primary-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = var.primary_location

  managed_redis = {
    sku_name = "Balanced_B3"
  }

  default_database = {
    geo_replication_group_name = var.geo_replication_group_name
  }

  geo_replication = {
    linked_managed_redis_ids = [module.managed_redis_secondary.id]
  }

  tags = {
    Environment = "Development"
    Example     = "GeoReplicationPrimary"
  }
}
