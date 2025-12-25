# Flow log unit tests for Network Security Group module

mock_provider "azurerm" {
  mock_resource "azurerm_network_security_group" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/test-nsg"
      name = "test-nsg"
    }
  }

  mock_resource "azurerm_network_watcher_flow_log" {}
}

variables {
  name                = "test-nsg"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "flow_log_valid" {
  command = plan

  variables {
    flow_log = {
      name                                = "nsg-flow-logs"
      storage_account_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
      network_watcher_name                = "NetworkWatcher_northeurope"
      network_watcher_resource_group_name = "NetworkWatcherRG"
      retention_policy = {
        enabled = true
        days    = 30
      }
      traffic_analytics = {
        enabled               = true
        workspace_id          = "00000000-0000-0000-0000-000000000000"
        workspace_region      = "northeurope"
        workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
        interval_in_minutes   = 10
      }
    }
  }

  assert {
    condition     = azurerm_network_watcher_flow_log.network_watcher_flow_log[0].enabled == true
    error_message = "Flow log should be enabled by default."
  }
}

run "flow_log_missing_storage" {
  command = plan

  variables {
    flow_log = {
      name                                = "nsg-flow-logs"
      storage_account_id                  = ""
      network_watcher_name                = "NetworkWatcher_northeurope"
      network_watcher_resource_group_name = "NetworkWatcherRG"
    }
  }

  expect_failures = [
    var.flow_log,
  ]
}

run "flow_log_invalid_interval" {
  command = plan

  variables {
    flow_log = {
      name                                = "nsg-flow-logs"
      storage_account_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
      network_watcher_name                = "NetworkWatcher_northeurope"
      network_watcher_resource_group_name = "NetworkWatcherRG"
      traffic_analytics = {
        enabled               = true
        workspace_id          = "00000000-0000-0000-0000-000000000000"
        workspace_region      = "northeurope"
        workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
        interval_in_minutes   = 15
      }
    }
  }

  expect_failures = [
    var.flow_log,
  ]
}

run "flow_log_retention_requires_days" {
  command = plan

  variables {
    flow_log = {
      name                                = "nsg-flow-logs"
      storage_account_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
      network_watcher_name                = "NetworkWatcher_northeurope"
      network_watcher_resource_group_name = "NetworkWatcherRG"
      retention_policy = {
        enabled = true
        days    = 0
      }
    }
  }

  expect_failures = [
    var.flow_log,
  ]
}
