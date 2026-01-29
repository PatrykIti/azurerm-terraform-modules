# Output tests for Log Analytics Workspace module

mock_provider "azurerm" {
  mock_resource "azurerm_log_analytics_workspace" {
    defaults = {
      id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/lawunit"
      name                 = "lawunit"
      location             = "northeurope"
      resource_group_name  = "test-rg"
      sku                  = "PerGB2018"
      retention_in_days    = 30
      workspace_id         = "00000000-0000-0000-0000-000000000000"
      primary_shared_key   = "primary-key"
      secondary_shared_key = "secondary-key"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
  mock_resource "azurerm_log_analytics_solution" {}
  mock_resource "azurerm_log_analytics_data_export_rule" {}
  mock_resource "azurerm_log_analytics_datasource_windows_event" {}
  mock_resource "azurerm_log_analytics_datasource_windows_performance_counter" {}
  mock_resource "azurerm_log_analytics_storage_insights" {}
  mock_resource "azurerm_log_analytics_linked_service" {}
  mock_resource "azurerm_log_analytics_cluster" {}
  mock_resource "azurerm_log_analytics_cluster_customer_managed_key" {}
}

variables {
  name                = "lawunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/lawunit"
    error_message = "Output 'id' should return the Log Analytics Workspace ID."
  }

  assert {
    condition     = output.name == "lawunit"
    error_message = "Output 'name' should return the Log Analytics Workspace name."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }

  assert {
    condition     = output.sku == "PerGB2018"
    error_message = "Output 'sku' should return the workspace SKU."
  }

  assert {
    condition     = output.retention_in_days == 30
    error_message = "Output 'retention_in_days' should return the retention setting."
  }

  assert {
    condition     = output.workspace_id == "00000000-0000-0000-0000-000000000000"
    error_message = "Output 'workspace_id' should return the workspace ID (customer ID)."
  }
}
