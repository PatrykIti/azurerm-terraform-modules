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

module "service_plan" {
  source = "../../"

  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  service_plan = {
    os_type                  = "Linux"
    sku_name                 = "S1"
    worker_count             = 1
    per_site_scaling_enabled = true
  }

  diagnostic_settings = [
    {
      name                       = "asp-complete"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      log_categories             = ["AppServiceConsoleLogs"]
      metric_categories          = ["AllMetrics"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
