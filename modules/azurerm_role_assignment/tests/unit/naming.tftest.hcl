# Naming tests for Role Assignment module

mock_provider "azurerm" {
  mock_resource "azurerm_role_assignment" {}
}

variables {
  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg"
  role_definition_name = "Reader"
  principal_id         = "00000000-0000-0000-0000-000000000000"
}

run "invalid_name_guid" {
  command = plan

  variables {
    name = "not-a-guid"
  }

  expect_failures = [
    var.name
  ]
}
