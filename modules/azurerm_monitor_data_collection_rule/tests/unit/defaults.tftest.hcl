# Defaults tests for Monitor Data Collection Rule module

mock_provider "azurerm" {
  mock_resource "azurerm_monitor_data_collection_rule" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/dataCollectionRules/dcrunit"
      name                = "dcrunit"
      location            = "northeurope"
      resource_group_name = "test-rg"
      kind                = "Windows"
      tags                = {}
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "dcrunit"
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

run "verify_tags_default" {
  command = plan

  assert {
    condition     = length(var.tags) == 0
    error_message = "tags should be empty by default."
  }
}
