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
  name     = "rg-appins-secure-${var.random_suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-appins-secure-${var.random_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "application_insights" {
  source = "../../.."

  name                = "appi-secure-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.example.id

  internet_ingestion_enabled    = false
  internet_query_enabled        = false
  local_authentication_disabled = true
  disable_ip_masking            = false

  tags = var.tags
}
