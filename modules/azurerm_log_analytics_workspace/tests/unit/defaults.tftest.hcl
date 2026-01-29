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
    condition     = var.workspace.sku == "PerGB2018"
    error_message = "workspace.sku should default to PerGB2018."
  }

  assert {
    condition     = var.workspace.retention_in_days == 30
    error_message = "workspace.retention_in_days should default to 30."
  }

  assert {
    condition     = var.workspace.internet_ingestion_enabled == true
    error_message = "workspace.internet_ingestion_enabled should default to true."
  }

  assert {
    condition     = var.workspace.internet_query_enabled == true
    error_message = "workspace.internet_query_enabled should default to true."
  }

  assert {
    condition     = var.workspace.local_authentication_enabled == true
    error_message = "workspace.local_authentication_enabled should default to true."
  }

  assert {
    condition     = var.workspace.daily_quota_gb == null
    error_message = "workspace.daily_quota_gb should default to null."
  }

  assert {
    condition     = var.workspace.reservation_capacity_in_gb_per_day == null
    error_message = "workspace.reservation_capacity_in_gb_per_day should default to null."
  }
}
