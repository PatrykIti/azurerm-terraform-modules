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
  name     = "rg-managed-redis-diag-example"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-managed-redis-diag"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "managed_redis" {
  source = "../../"

  name                = "managed-redis-diag-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  managed_redis = {
    sku_name = "Balanced_B3"
  }

  monitoring = [
    {
      name                       = "managed-redis-diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      log_categories             = ["ConnectionEvents"]
      metric_categories          = ["AllMetrics"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "DiagnosticSettings"
  }
}
