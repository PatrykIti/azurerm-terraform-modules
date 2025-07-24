# Test flow log configurations for Network Security Group module

# Mock the Azure provider to avoid real API calls
mock_provider "azurerm" {
  mock_resource "azurerm_network_security_group" {
    defaults = {
      id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/test-nsg"
    }
  }

  mock_resource "azurerm_network_watcher_flow_log" {
    defaults = {
      id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/networkWatchers/test-nw/flowLogs/test-flow-log"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {
    defaults = {
      id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/test-nsg|test-diag"
    }
  }

  mock_data "azurerm_network_watcher" {
    defaults = {
      id                  = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/networkWatchers/test-nw"
      name                = "test-nw"
      location            = "northeurope"
      resource_group_name = "test-rg"
    }
  }
}

variables {
  name                = "test-nsg"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

# Test flow logs enabled with minimal configuration
run "flow_logs_enabled_minimal" {
  command = plan

  variables {
    flow_log_enabled            = true
    network_watcher_name        = "test-nw"
    flow_log_storage_account_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
  }

  assert {
    condition     = length(azurerm_network_watcher_flow_log.flow_log) == 1
    error_message = "Flow log should be created when enabled"
  }

  assert {
    condition     = azurerm_network_watcher_flow_log.flow_log[0].enabled == true
    error_message = "Flow log should be enabled"
  }

  assert {
    condition     = azurerm_network_watcher_flow_log.flow_log[0].storage_account_id == "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
    error_message = "Flow log storage account should be set"
  }

  assert {
    condition     = azurerm_network_watcher_flow_log.flow_log[0].version == 2
    error_message = "Flow log version should default to 2"
  }
}

# Test flow logs with retention policy
run "flow_logs_with_retention" {
  command = plan

  variables {
    flow_log_enabled            = true
    network_watcher_name        = "test-nw"
    flow_log_storage_account_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
    flow_log_retention_in_days  = 30
  }

  assert {
    condition     = azurerm_network_watcher_flow_log.flow_log[0].retention_policy[0].enabled == true
    error_message = "Flow log retention policy should be enabled"
  }

  assert {
    condition     = azurerm_network_watcher_flow_log.flow_log[0].retention_policy[0].days == 30
    error_message = "Flow log retention should be 30 days"
  }
}

# Test flow logs with traffic analytics
run "flow_logs_with_traffic_analytics" {
  command = plan

  variables {
    flow_log_enabled                         = true
    network_watcher_name                     = "test-nw"
    flow_log_storage_account_id              = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
    traffic_analytics_enabled                = true
    traffic_analytics_workspace_id           = "12345678-1234-1234-1234-123456789012"
    traffic_analytics_workspace_resource_id  = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
    traffic_analytics_workspace_region       = "northeurope"
    traffic_analytics_interval_in_minutes    = 10
  }

  assert {
    condition     = azurerm_network_watcher_flow_log.flow_log[0].traffic_analytics[0].enabled == true
    error_message = "Traffic analytics should be enabled"
  }

  assert {
    condition     = azurerm_network_watcher_flow_log.flow_log[0].traffic_analytics[0].workspace_id == "12345678-1234-1234-1234-123456789012"
    error_message = "Traffic analytics workspace ID should be set"
  }

  assert {
    condition     = azurerm_network_watcher_flow_log.flow_log[0].traffic_analytics[0].workspace_resource_id == "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
    error_message = "Traffic analytics workspace resource ID should be set"
  }

  assert {
    condition     = azurerm_network_watcher_flow_log.flow_log[0].traffic_analytics[0].workspace_region == "northeurope"
    error_message = "Traffic analytics workspace region should be set"
  }

  assert {
    condition     = azurerm_network_watcher_flow_log.flow_log[0].traffic_analytics[0].interval_in_minutes == 10
    error_message = "Traffic analytics interval should be 10 minutes"
  }
}

# Test flow logs version 1
run "flow_logs_version_1" {
  command = plan

  variables {
    flow_log_enabled            = true
    network_watcher_name        = "test-nw"
    flow_log_storage_account_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
    flow_log_version            = 1
  }

  assert {
    condition     = azurerm_network_watcher_flow_log.flow_log[0].version == 1
    error_message = "Flow log version should be 1 when specified"
  }
}


# Test flow logs without traffic analytics
run "flow_logs_no_traffic_analytics" {
  command = plan

  variables {
    flow_log_enabled            = true
    network_watcher_name        = "test-nw"
    flow_log_storage_account_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
    traffic_analytics_enabled   = false
  }

  assert {
    condition     = length(azurerm_network_watcher_flow_log.flow_log[0].traffic_analytics) == 0
    error_message = "Traffic analytics should not be configured when disabled"
  }
}

# Test diagnostic settings enabled
run "diagnostic_settings_enabled" {
  command = plan

  variables {
    diagnostic_settings = {
      name                       = "test-diag"
      log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      log_categories             = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
    }
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.diagnostic_settings) == 1
    error_message = "Diagnostic setting should be created when configuration is provided"
  }

  assert {
    condition     = azurerm_monitor_diagnostic_setting.diagnostic_settings[0].name == "test-diag"
    error_message = "Diagnostic setting name should match"
  }

  assert {
    condition     = azurerm_monitor_diagnostic_setting.diagnostic_settings[0].log_analytics_workspace_id == "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
    error_message = "Diagnostic setting workspace should be set"
  }
}

# Test diagnostic settings with storage account
run "diagnostic_settings_with_storage" {
  command = plan

  variables {
    diagnostic_settings = {
      name               = "test-diag"
      storage_account_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
      log_categories     = ["NetworkSecurityGroupEvent"]
      metric_categories  = ["AllMetrics"]
    }
  }

  assert {
    condition     = azurerm_monitor_diagnostic_setting.diagnostic_settings[0].storage_account_id == "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
    error_message = "Diagnostic setting storage account should be set"
  }
}

# Test diagnostic settings disabled by default
run "diagnostic_settings_disabled_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.diagnostic_settings) == 0
    error_message = "Diagnostic settings should be disabled by default"
  }
}