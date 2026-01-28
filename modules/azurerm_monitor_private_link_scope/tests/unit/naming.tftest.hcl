# Naming validation tests for Monitor Private Link Scope module

mock_provider "azurerm" {
  mock_resource "azurerm_monitor_private_link_scope" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/privateLinkScopes/amplsunit"
      name = "amplsunit"
    }
  }

  mock_resource "azurerm_monitor_private_link_scoped_service" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  resource_group_name = "test-rg"
}

run "invalid_name_underscore" {
  command = plan

  variables {
    name = "ampls_invalid"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_too_long" {
  command = plan

  variables {
    name = "ampls1234567890123456789012345678901234567890123456789012345678901"
  }

  expect_failures = [
    var.name
  ]
}
