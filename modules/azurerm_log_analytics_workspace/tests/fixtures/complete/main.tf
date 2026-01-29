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
  name     = "rg-law-complete-${var.random_suffix}"
  location = var.location
}

resource "azurerm_storage_account" "diagnostics" {
  name                     = "stlawcomp${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "log_analytics_workspace" {
  source = "../../.."

  name                = "law-complete-${var.random_suffix}"
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

  tags = var.tags
}
