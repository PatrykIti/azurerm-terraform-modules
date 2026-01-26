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
  name     = "rg-dcr-basic-${var.random_suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-dcr-basic-${var.random_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "monitor_data_collection_rule" {
  source = "../../../"

  name                = "dcrbasic${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kind                = "Windows"

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
        streams        = ["Microsoft-WindowsEvent"]
        x_path_queries = ["Application!*[System[(Level=1 or Level=2)]]"]
      }
    ]
  }

  data_flows = [
    {
      streams      = ["Microsoft-WindowsEvent"]
      destinations = ["log-analytics"]
    }
  ]

  tags = var.tags
}
