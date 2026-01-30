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
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "monitor_data_collection_endpoint" {
  source = "../../../azurerm_monitor_data_collection_endpoint"

  name                = var.data_collection_endpoint_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kind                = var.kind

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}

module "monitor_data_collection_rule" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_monitor_data_collection_rule?ref=DCRv1.0.0"

  name                = var.data_collection_rule_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  description         = var.description
  kind                = var.kind

  data_collection_endpoint_id = module.monitor_data_collection_endpoint.id

  identity = {
    type = "SystemAssigned"
  }

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
    performance_counter = [
      {
        name                          = "perf"
        streams                       = ["Microsoft-Perf"]
        counter_specifiers            = ["\\Processor(_Total)\\% Processor Time"]
        sampling_frequency_in_seconds = 60
      }
    ]
  }

  data_flows = [
    {
      streams      = ["Microsoft-Event"]
      destinations = ["log-analytics"]
    },
    {
      streams      = ["Microsoft-Perf"]
      destinations = ["log-analytics"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
