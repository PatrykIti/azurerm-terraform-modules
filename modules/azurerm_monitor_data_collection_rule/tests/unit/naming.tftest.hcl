# Naming validation tests for Monitor Data Collection Rule module

mock_provider "azurerm" {
  mock_resource "azurerm_monitor_data_collection_rule" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/dataCollectionRules/dcrunit"
      name = "dcrunit"
    }
  }

  mock_resource "azurerm_monitor_data_collection_rule_association" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  resource_group_name = "test-rg"
  location            = "northeurope"
  destinations = {
    log_analytics = [
      {
        name                  = "log-analytics"
        workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/ws"
      }
    ]
  }
  data_flows = [
    {
      streams      = ["Microsoft-Perf"]
      destinations = ["log-analytics"]
    }
  ]
}

run "invalid_name_underscore" {
  command = plan

  variables {
    name = "dcr_invalid"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_too_long" {
  command = plan

  variables {
    name = "dcr1234567890123456789012345678901234567890123456789012345678901"
  }

  expect_failures = [
    var.name
  ]
}
