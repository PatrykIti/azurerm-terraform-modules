# Defaults tests for Role Definition module

mock_provider "azurerm" {
  mock_resource "azurerm_role_definition" {}
}

variables {
  name  = "custom-role-defaults"
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

run "verify_defaults" {
  command = plan

  assert {
    condition     = var.description == null
    error_message = "description should default to null."
  }

  assert {
    condition     = var.role_definition_id == null
    error_message = "role_definition_id should default to null."
  }

  assert {
    condition     = var.timeouts.create == null
    error_message = "timeouts.create should default to null."
  }
}
