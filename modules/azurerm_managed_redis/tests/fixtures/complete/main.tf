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
  name     = "rg-amr-complete-${var.random_suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "lawamr${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "managed_redis" {
  source = "../../../"

  name                = "amrcomplete${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  managed_redis = {
    sku_name = "Balanced_B5"
  }

  default_database = {
    access_keys_authentication_enabled = true
    geo_replication_group_name         = var.geo_replication_group_name
    modules = [
      {
        name = "RediSearch"
      },
      {
        name = "RedisJSON"
      }
    ]
  }

  monitoring = [
    {
      name                       = "diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      log_categories             = ["ConnectionEvents"]
      metric_categories          = ["AllMetrics"]
    }
  ]

  tags = var.tags
}
