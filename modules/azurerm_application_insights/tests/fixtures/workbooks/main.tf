terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-appins-workbooks-${var.random_suffix}"
  location = var.location
}

resource "random_uuid" "workbook" {}

module "application_insights" {
  source = "../../.."

  name                = "appi-workbooks-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type    = "web"

  workbooks = [
    {
      name         = random_uuid.workbook.result
      display_name = "Application Insights Overview"
      data_json = jsonencode({
        version = "Notebook/1.0"
        items   = []
        metadata = {
          category = "Application Insights"
        }
      })
    }
  ]

  tags = var.tags
}
