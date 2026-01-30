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
  name     = "rg-aiwb-identity-${var.random_suffix}"
  location = var.location
}

locals {
  workbook_data = {
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        name = "text-1"
        content = {
          json = "## Identity Workbook Test"
        }
      }
    ]
    fallbackResourceIds = []
  }
}

module "application_insights_workbook" {
  source = "../../.."

  name                = "9c1a4e2b-1d2f-4d3a-8f1b-2b3c4d5e6f04"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  display_name        = "Workbook - Identity Test"
  data_json           = jsonencode(local.workbook_data)

  identity = {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Test"
    Example     = "WorkbookIdentity"
  }
}
