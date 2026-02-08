# Diagnostic settings tests for Cognitive Account module

mock_provider "azurerm" {
  mock_resource "azurerm_cognitive_account" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/cogunit"
      name = "cogunit"
    }
  }
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                  = "cogunit"
  resource_group_name   = "test-rg"
  location              = "westeurope"
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = "cogunit"
}

run "diagnostic_settings_valid" {
  command = apply

  variables {
    diagnostic_settings = [
      {
        name                       = "diag"
        log_category_groups        = ["allLogs"]
        metric_categories          = ["AllMetrics"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/law"
      }
    ]
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 0
    error_message = "diagnostic_settings_skipped should remain empty when explicit categories are used."
  }
}
