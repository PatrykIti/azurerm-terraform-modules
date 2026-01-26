# Validation tests for Monitor Data Collection Rule module

mock_provider "azurerm" {
  mock_resource "azurerm_monitor_data_collection_rule" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/dataCollectionRules/dcrunit"
      name = "dcrunit"
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

run "missing_destinations" {
  command = plan

  variables {
    destinations = {}
  }

  expect_failures = [
    var.destinations
  ]
}

run "missing_data_flows" {
  command = plan

  variables {
    data_flows = []
  }

  expect_failures = [
    var.data_flows
  ]
}

run "duplicate_destination_names" {
  command = plan

  variables {
    destinations = {
      azure_monitor_metrics = {
        name = "log-analytics"
      }
      log_analytics = [
        {
          name                  = "log-analytics"
          workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/ws"
        }
      ]
    }
  }

  expect_failures = [
    var.destinations
  ]
}

run "linux_with_windows_event_log" {
  command = plan

  variables {
    kind = "Linux"
    data_sources = {
      windows_event_log = [
        {
          name           = "windows-events"
          streams        = ["Microsoft-WindowsEvent"]
          x_path_queries = ["Application!*[System[(Level=1 or Level=2)]]"]
        }
      ]
    }
  }

  expect_failures = [
    var.data_sources
  ]
}
