# Output tests for Role Definition module

mock_provider "azurerm" {
  mock_resource "azurerm_role_definition" {
    defaults = {
      id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/22222222-2222-2222-2222-222222222222"
      role_definition_id = "22222222-2222-2222-2222-222222222222"
      name               = "custom-role-output"
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      assignable_scopes  = ["/subscriptions/00000000-0000-0000-0000-000000000000"]
      description        = "Custom role description"
    }
  }
}

variables {
  name  = "custom-role-output"
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

run "verify_outputs" {
  command = apply

  assert {
    condition     = output.role_definition_id == "22222222-2222-2222-2222-222222222222"
    error_message = "Output 'role_definition_id' should return the role definition ID."
  }

  assert {
    condition     = output.name == "custom-role-output"
    error_message = "Output 'name' should return the role definition name."
  }

  assert {
    condition     = output.scope == "/subscriptions/00000000-0000-0000-0000-000000000000"
    error_message = "Output 'scope' should return the scope."
  }
}
