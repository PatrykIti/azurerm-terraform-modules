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
  name     = "rg-amr-geo-${var.random_suffix}"
  location = var.location
}

module "managed_redis_secondary" {
  source = "../../../"

  name                = "amrsec${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = var.secondary_location

  managed_redis = {
    sku_name = "Balanced_B3"
  }

  default_database = {
    geo_replication_group_name = var.geo_replication_group_name
  }
}

module "managed_redis_primary" {
  source = "../../../"

  name                = "amrpri${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  managed_redis = {
    sku_name = "Balanced_B3"
  }

  default_database = {
    geo_replication_group_name = var.geo_replication_group_name
  }

  geo_replication = {
    linked_managed_redis_ids = [module.managed_redis_secondary.id]
  }
}
