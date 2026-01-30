# Diagnostic settings tests for Cognitive Account module

mock_provider "azurerm" {
  mock_resource "azurerm_cognitive_account" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/cogunit"
      name = "cogunit"
    }
  }
  mock_resource "azurerm_monitor_diagnostic_setting" {}
  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types   = ["AuditEvent"]
      log_category_groups  = ["allLogs"]
      metrics              = ["AllMetrics"]
    }
  }
}

variables {
  name                = "cogunit"
  resource_group_name = "test-rg"
  location            = "westeurope"
  kind                = "OpenAI"
  sku_name            = "S0"
  custom_subdomain_name = "cogunit"
}

run "diagnostic_settings_valid" {
  command = apply

  variables {
    diagnostic_settings = [
      {
        name                       = "diag"
        areas                      = ["all"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/law"
      }
    ]
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 0
    error_message = "diagnostic_settings_skipped should be empty when areas resolve categories."
  }
}

run "diagnostic_settings_skips_empty" {
  command = apply

  variables {
    diagnostic_settings = [
      {
        name                       = "diag-empty"
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/law"
        log_categories             = []
        metric_categories          = []
        log_category_groups        = []
      }
    ]
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 1
    error_message = "diagnostic_settings_skipped should capture empty categories."
  }
}
