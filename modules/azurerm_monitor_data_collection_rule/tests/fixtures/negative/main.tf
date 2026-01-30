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
  name     = "rg-dcr-negative-${var.random_suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-dcr-negative-${var.random_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "monitor_data_collection_endpoint" {
  source = "../../../../azurerm_monitor_data_collection_endpoint"

  name                = "dcenegative${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kind                = "Windows"
}

# Invalid name (underscore is not allowed by module validation)
module "monitor_data_collection_rule" {
  source = "../../../"

  name                = "dcr_invalid_${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kind                = "Windows"

  data_collection_endpoint_id = module.monitor_data_collection_endpoint.id

  destinations = {
    log_analytics = [
      {
        name                  = "log-analytics"
        workspace_resource_id = azurerm_log_analytics_workspace.example.id
      }
    ]
  }

  data_sources = {
    windows_event_log = [
      {
        name           = "windows-events"
        streams        = ["Microsoft-Event"]
        x_path_queries = ["Application!*[System[(Level=1 or Level=2)]]"]
      }
    ]
  }

  data_flows = [
    {
      streams      = ["Microsoft-Event"]
      destinations = ["log-analytics"]
    }
  ]
}
