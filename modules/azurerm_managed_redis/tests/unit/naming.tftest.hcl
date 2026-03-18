# Naming tests for Managed Redis module

mock_provider "azurerm" {
  mock_resource "azurerm_managed_redis" {}
  mock_resource "azurerm_managed_redis_geo_replication" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "managedredisunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  managed_redis = {
    sku_name = "Balanced_B3"
  }
}

run "invalid_name_format" {
  command = plan

  variables {
    name = "-invalid"
  }

  expect_failures = [
    var.name,
  ]
}
