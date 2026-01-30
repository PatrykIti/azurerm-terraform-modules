# Naming validation tests for Application Insights module

mock_provider "azurerm" {
  mock_resource "azurerm_application_insights" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "appinsunit"
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
