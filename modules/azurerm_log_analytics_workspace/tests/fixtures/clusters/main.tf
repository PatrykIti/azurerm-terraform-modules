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
  name     = "rg-law-cluster-${var.random_suffix}"
  location = var.location
}

module "log_analytics_workspace" {
  source = "../../.."

  name                = "law-cluster-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  workspace = {
    sku               = "PerGB2018"
    retention_in_days = 30
  }

  features = {
    clusters = [
      {
        name     = "law-cluster-${var.random_suffix}"
        location = var.cluster_location
        identity = {
          type = "SystemAssigned"
        }
      }
    ]
  }

  tags = var.tags
}
