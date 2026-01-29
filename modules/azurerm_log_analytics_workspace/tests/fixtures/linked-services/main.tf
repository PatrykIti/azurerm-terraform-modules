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
  name     = "rg-law-linked-${var.random_suffix}"
  location = var.location
}

resource "azurerm_automation_account" "example" {
  name                = "aa-law-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "Basic"
}

module "log_analytics_workspace" {
  source = "../../.."

  name                = "law-linked-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  workspace = {
    sku               = "PerGB2018"
    retention_in_days = 30
  }

  features = {
    linked_services = [
      {
        name           = "automation"
        read_access_id = azurerm_automation_account.example.id
      }
    ]
  }

  tags = var.tags
}
