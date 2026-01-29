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
  name     = "rg-law-event-${var.random_suffix}"
  location = var.location
}

module "log_analytics_workspace" {
  source = "../../.."

  name                = "law-event-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "PerGB2018"
  retention_in_days   = 30

  windows_event_datasources = [
    {
      name           = "events-application"
      event_log_name = "Application"
      event_types    = ["Error", "Warning"]
    }
  ]

  tags = var.tags
}
