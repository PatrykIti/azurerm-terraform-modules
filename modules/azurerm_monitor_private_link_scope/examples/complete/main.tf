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

resource "azurerm_application_insights" "example" {
  name                = var.application_insights_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
}

resource "azurerm_monitor_data_collection_endpoint" "example" {
  name                = var.data_collection_endpoint_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "Linux"
}

module "monitor_private_link_scope" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_monitor_private_link_scope?ref=AMPLSv1.0.0"

  name                = var.scope_name
  resource_group_name = azurerm_resource_group.example.name

  ingestion_access_mode = "PrivateOnly"
  query_access_mode     = "Open"

  scoped_services = [
    {
      name               = "ampls-law"
      linked_resource_id = azurerm_log_analytics_workspace.example.id
    },
    {
      name               = "ampls-appi"
      linked_resource_id = azurerm_application_insights.example.id
    },
    {
      name               = "ampls-dce"
      linked_resource_id = azurerm_monitor_data_collection_endpoint.example.id
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
