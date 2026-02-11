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

resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "redis_cache" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_redis_cache?ref=REDISv1.0.0"

  name                = var.redis_cache_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name = "Standard"
  family   = "C"
  capacity = 1

  diagnostic_settings = [
    {
      name                       = "redis-diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      metric_categories          = ["AllMetrics"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Diagnostic-Settings"
  }
}
