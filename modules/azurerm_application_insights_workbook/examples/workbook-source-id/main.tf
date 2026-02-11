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
  name     = "rg-application_insights_workbook-source-example"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-aiwb-source-example"
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
          json = "## Workbook Source ID Example"
        }
      }
    ]
    fallbackResourceIds = []
  }
}

module "application_insights_workbook" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_application_insights_workbook?ref=AIWBv1.0.0"

  name                = "1e2f3a4b-5c6d-4e7f-8a9b-0c1d2e3f4a05"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  display_name        = "Workbook - Source ID"
  data_json           = jsonencode(local.workbook_data)
  source_id           = lower(azurerm_log_analytics_workspace.example.id)

  tags = {
    Environment = "Development"
    Example     = "WorkbookSourceId"
  }
}
