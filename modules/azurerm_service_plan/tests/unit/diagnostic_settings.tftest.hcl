# Diagnostic settings unit tests for App Service Plan module

mock_provider "azurerm" {
  mock_resource "azurerm_service_plan" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/aspunit"
      name = "aspunit"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "aspunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  service_plan = {
    os_type  = "Linux"
    sku_name = "P1v3"
  }
}

run "diagnostic_settings_valid" {
  command = apply

  variables {
    diagnostic_settings = [
      {
        name                       = "asp-diag"
        log_categories             = ["AppServiceConsoleLogs"]
        metric_categories          = ["AllMetrics"]
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
