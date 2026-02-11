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

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-diag-${var.random_suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "lawkvdiag${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "key_vault" {
  source = "../../../"

  name                = "kvdiag${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  rbac_authorization_enabled    = false
  public_network_access_enabled = true

  access_policies = [
    {
      name               = "current-user"
      object_id          = data.azurerm_client_config.current.object_id
      tenant_id          = data.azurerm_client_config.current.tenant_id
      secret_permissions = ["Get", "List", "Set", "Delete"]
    }
  ]

  diagnostic_settings = [
    {
      name                       = "diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      log_category_groups        = ["allLogs"]
      metric_categories          = ["AllMetrics"]
    }
  ]

  tags = {
    Environment = "Test"
    TestType    = "Diagnostics"
  }
}
