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
  name     = "rg-law-secure-${var.random_suffix}"
  location = var.location
}

module "log_analytics_workspace" {
  source = "../../.."

  name                = "law-secure-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku                           = "PerGB2018"
  retention_in_days             = 30
  internet_ingestion_enabled    = false
  internet_query_enabled        = false
  local_authentication_enabled = false

  tags = var.tags
}
