# Naming tests for Linux Function App module

mock_provider "azurerm" {
  mock_resource "azurerm_linux_function_app" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "funcunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  service_plan_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/plan"
  storage_configuration = {
    account_name       = "stunit001"
    account_access_key = "fakekey"
  }
  site_configuration = {
    application_stack = {
      node_version = "20"
    }
  }
}

run "invalid_name" {
  command = plan

  variables {
    name = "Invalid_Name"
  }

  expect_failures = [
    var.name
  ]
}
