# Diagnostic settings unit tests for PostgreSQL Flexible Server module

mock_provider "azurerm" {
  mock_resource "azurerm_postgresql_flexible_server" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit"
      name = "pgfsunit"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}

  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types = ["PostgreSQLLogs"]
      metrics            = ["AllMetrics"]
    }
  }
}

variables {
  name                   = "pgfsunit"
  resource_group_name    = "test-rg"
  location               = "northeurope"
  sku_name               = "GP_Standard_D2s_v3"
  postgresql_version     = "15"
  administrator_login    = "pgfsadmin"
  administrator_password = "Password1234"
}

run "diagnostic_settings_valid" {
  command = apply

  variables {
    diagnostic_settings = [
      {
        name                       = "pgfs-diag"
        areas                      = ["all"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      }
    ]
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 0
    error_message = "No diagnostic settings should be skipped when categories are available."
  }
}

run "diagnostic_settings_skips_empty_categories" {
  command = apply

  variables {
    diagnostic_settings = [
      {
        name                       = "empty-categories"
        log_categories             = []
        metric_categories          = []
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      }
    ]
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 1
    error_message = "Entries with no categories should be reported as skipped."
  }

  assert {
    condition     = output.diagnostic_settings_skipped[0].name == "empty-categories"
    error_message = "Skipped entry should include the original name."
  }
}
