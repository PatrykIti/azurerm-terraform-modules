# Defaults tests for Log Analytics Workspace module

mock_provider "azurerm" {
  mock_resource "azurerm_log_analytics_workspace" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/lawunit"
      name                = "lawunit"
      location            = "northeurope"
      resource_group_name = "test-rg"
      sku                 = "PerGB2018"
      retention_in_days   = 30
      workspace_id        = "00000000-0000-0000-0000-000000000000"
      primary_shared_key  = "primary-key"
      secondary_shared_key = "secondary-key"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "lawunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "verify_defaults" {
  command = plan

  assert {
    condition     = var.sku == "PerGB2018"
    error_message = "sku should default to PerGB2018."
  }

  assert {
    condition     = var.retention_in_days == 30
    error_message = "retention_in_days should default to 30."
  }

  assert {
    condition     = var.internet_ingestion_enabled == true
    error_message = "internet_ingestion_enabled should default to true."
  }

  assert {
    condition     = var.internet_query_enabled == true
    error_message = "internet_query_enabled should default to true."
  }

  assert {
    condition     = var.local_authentication_disabled == false
    error_message = "local_authentication_disabled should default to false."
  }

  assert {
    condition     = var.daily_quota_gb == null
    error_message = "daily_quota_gb should default to null."
  }

  assert {
    condition     = var.reservation_capacity_in_gb_per_day == null
    error_message = "reservation_capacity_in_gb_per_day should default to null."
  }
}
