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
  name     = "rg-law-perf-${var.random_suffix}"
  location = var.location
}

module "log_analytics_workspace" {
  source = "../../.."

  name                = "law-perf-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "PerGB2018"
  retention_in_days   = 30

  windows_performance_counters = [
    {
      name             = "perf-cpu"
      object_name      = "Processor"
      instance_name    = "*"
      counter_name     = "% Processor Time"
      interval_seconds = 10
    }
  ]

  tags = var.tags
}
