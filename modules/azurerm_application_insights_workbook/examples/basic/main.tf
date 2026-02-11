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
  name     = "rg-application_insights_workbook-basic-example"
  location = "West Europe"
}

locals {
  workbook_data = {
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        name = "text-1"
        content = {
          json = "## Basic Workbook"
        }
      }
    ]
    fallbackResourceIds = []
  }
}

module "application_insights_workbook" {
  source = "../../"

  name                = "2f9c2f59-3f8b-4d8b-8a2c-1d9b3b2a0f01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  display_name        = "Workbook - Basic"
  data_json           = jsonencode(local.workbook_data)

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
