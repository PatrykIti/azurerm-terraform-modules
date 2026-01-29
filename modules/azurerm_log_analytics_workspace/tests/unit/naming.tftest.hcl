# Naming validation tests for Log Analytics Workspace module

mock_provider "azurerm" {
  mock_resource "azurerm_log_analytics_workspace" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "lawunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "invalid_name" {
  command = plan

  variables {
    name = "invalid name with spaces"
  }

  expect_failures = [
    var.name
  ]
}
