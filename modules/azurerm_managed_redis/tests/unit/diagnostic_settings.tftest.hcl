# Diagnostic settings tests for Managed Redis module

mock_provider "azurerm" {
  mock_resource "azurerm_managed_redis" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/managedredisunit"
      default_database = {
        id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/managedredisunit/databases/default"
        port = 10000
      }
    }
  }
  mock_resource "azurerm_managed_redis_geo_replication" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "managedredisunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  managed_redis = {
    sku_name = "Balanced_B3"
  }
}

run "diagnostic_setting_created" {
  command = plan

  variables {
    monitoring = [
      {
        name                       = "diag"
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/law"
        log_categories             = ["ConnectionEvents"]
        metric_categories          = ["AllMetrics"]
      }
    ]
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings_logs) == 1
    error_message = "A log diagnostic setting should be created when log categories are supplied."
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings_metrics) == 1
    error_message = "A metric diagnostic setting should be created when metric categories are supplied."
  }
}

run "diagnostic_setting_skipped_without_categories" {
  command = apply

  variables {
    monitoring = [
      {
        name                       = "diag"
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/law"
      }
    ]
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 1
    error_message = "diagnostic_settings_skipped should contain monitoring entries without categories."
  }
}
