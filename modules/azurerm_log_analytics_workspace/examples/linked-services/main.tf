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

resource "azurerm_automation_account" "example" {
  name                = var.automation_account_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "Basic"
}

module "log_analytics_workspace" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_log_analytics_workspace?ref=LAWv1.1.0"

  name                = var.workspace_name
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

  tags = {
    Environment = "Development"
    Example     = "Linked Services"
  }
}
