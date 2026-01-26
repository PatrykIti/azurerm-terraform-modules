# Naming validation tests for Monitor Data Collection Endpoint module

mock_provider "azurerm" {
  mock_resource "azurerm_monitor_data_collection_endpoint" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/dataCollectionEndpoints/dceunit"
      name = "dceunit"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "invalid_name_underscore" {
  command = plan

  variables {
    name = "dce_invalid"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_too_long" {
  command = plan

  variables {
    name = "dce1234567890123456789012345678901234567890123456789012345678901"
  }

  expect_failures = [
    var.name
  ]
}
