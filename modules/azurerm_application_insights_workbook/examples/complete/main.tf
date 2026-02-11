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
  name     = "rg-application_insights_workbook-complete-example"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-aiwb-complete-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "example" {
  name                     = "staiwbcompleteexample"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "workbook" {
  name                  = "workbook-storage"
  storage_account_id    = azurerm_storage_account.example.id
  container_access_type = "private"
}

resource "azurerm_user_assigned_identity" "workbook" {
  name                = "uai-aiwb-complete-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_role_assignment" "workbook_reader" {
  scope                = azurerm_log_analytics_workspace.example.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.workbook.principal_id
}

resource "azurerm_role_assignment" "workbook_storage_contributor" {
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Contributor"
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
          json = "## Complete Workbook"
        }
      }
    ]
    fallbackResourceIds = []
  }
}

module "application_insights_workbook" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_application_insights_workbook?ref=AIWBv1.0.0"

  name                 = "6b8b7d76-5d1a-4d4a-9b1c-9f5b8c2f0a02"
  resource_group_name  = azurerm_resource_group.example.name
  location             = azurerm_resource_group.example.location
  display_name         = "Workbook - Complete"
  data_json            = jsonencode(local.workbook_data)
  description          = "Complete example workbook with identity and source."
  category             = "workbook"
  source_id            = lower(azurerm_log_analytics_workspace.example.id)
  storage_container_id = azurerm_storage_container.workbook.id

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.workbook.id]
  }

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }

  depends_on = [
    azurerm_role_assignment.workbook_reader,
    azurerm_role_assignment.workbook_storage_contributor
  ]
}
