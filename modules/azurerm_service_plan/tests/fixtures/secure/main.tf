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

locals {
  suffix                       = substr(var.random_suffix, 0, 8)
  resource_group_name          = "rg-asp-secure-${local.suffix}"
  service_plan_name            = "asp-secure-${local.suffix}"
  log_analytics_workspace_name = "law-asp-secure-${local.suffix}"
}

resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = local.log_analytics_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "service_plan" {
  source = "../../../"

  name                = local.service_plan_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  service_plan = {
    os_type      = "Windows"
    sku_name     = "S1"
    worker_count = 1
  }

  diagnostic_settings = [
    {
      name                       = "asp-secure"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      metric_categories          = ["AllMetrics"]
    }
  ]

  tags = {
    Environment = "Test"
    Example     = "Secure"
  }
}
