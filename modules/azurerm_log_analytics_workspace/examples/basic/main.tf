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
  name     = var.resource_group_name
  location = var.location
}

module "log_analytics_workspace" {
  source = "../../"

  name                = var.workspace_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  workspace = {
    sku               = "PerGB2018"
    retention_in_days = 30
  }

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
