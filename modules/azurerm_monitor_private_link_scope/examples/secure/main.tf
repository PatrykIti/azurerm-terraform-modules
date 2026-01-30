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

resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "monitor_private_link_scope" {
  source = "../../"

  name                = var.scope_name
  resource_group_name = azurerm_resource_group.example.name

  ingestion_access_mode = "PrivateOnly"
  query_access_mode     = "PrivateOnly"

  scoped_services = [
    {
      name               = "ampls-law"
      linked_resource_id = azurerm_log_analytics_workspace.example.id
    }
  ]

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
