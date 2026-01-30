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

resource "azurerm_storage_account" "diagnostics" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "log_analytics_workspace" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_log_analytics_workspace?ref=LAWv1.0.0"

  name                = var.workspace_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  workspace = {
    sku                          = "PerGB2018"
    retention_in_days            = 90
    daily_quota_gb               = 5
    internet_ingestion_enabled   = true
    internet_query_enabled       = true
    local_authentication_enabled = true
  }

  monitoring = [
    {
      name               = "diag"
      metric_categories  = ["AllMetrics"]
      storage_account_id = azurerm_storage_account.diagnostics.id
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
