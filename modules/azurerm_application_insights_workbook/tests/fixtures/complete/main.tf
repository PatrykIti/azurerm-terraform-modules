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
  name     = "rg-aiwb-complete-${var.random_suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-aiwb-complete-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

locals {
  workbook_data = {
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        name = "text-1"
        content = {
          json = "## Complete Workbook Test"
        }
      }
    ]
    fallbackResourceIds = []
  }
}

module "application_insights_workbook" {
  source = "../../.."

  name                = "6b8b7d76-5d1a-4d4a-9b1c-9f5b8c2f0a02"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  display_name        = "Workbook - Complete Test"
  data_json           = jsonencode(local.workbook_data)
  description         = "Complete fixture workbook."
  category            = "workbook"
  source_id           = lower(azurerm_log_analytics_workspace.example.id)

  identity = {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Test"
    Example     = "Complete"
  }
}
