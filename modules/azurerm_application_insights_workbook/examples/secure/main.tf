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
  name     = "rg-application_insights_workbook-secure-example"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-aiwb-secure-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_user_assigned_identity" "workbook" {
  name                = "uai-aiwb-secure-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_role_assignment" "workbook_reader" {
  scope                = azurerm_log_analytics_workspace.example.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.workbook.principal_id
}

locals {
  workbook_data = {
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        name = "text-1"
        content = {
          json = "## Secure Workbook"
        }
      }
    ]
    fallbackResourceIds = []
  }
}

module "application_insights_workbook" {
  source = "../../"

  name                = "c0b9d8e6-7a21-4f0b-9d42-6c9b1e4f0b03"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  display_name        = "Workbook - Secure"
  data_json           = jsonencode(local.workbook_data)
  category            = "workbook"
  source_id           = lower(azurerm_log_analytics_workspace.example.id)

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.workbook.id]
  }

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
