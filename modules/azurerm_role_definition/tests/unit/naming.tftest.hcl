# Naming tests for Role Definition module

mock_provider "azurerm" {
  mock_resource "azurerm_role_definition" {}
}

variables {
  name  = "custom-role"
  scope = "/subscriptions/00000000-0000-0000-0000-000000000000"

  permissions = [
    {
      actions = [
        "Microsoft.Resources/subscriptions/resourceGroups/read"
      ]
    }
  ]

  assignable_scopes = [
    "/subscriptions/00000000-0000-0000-0000-000000000000"
  ]
}

run "empty_name" {
  command = plan

  variables {
    name = ""
  }

  expect_failures = [
    var.name
  ]
}
