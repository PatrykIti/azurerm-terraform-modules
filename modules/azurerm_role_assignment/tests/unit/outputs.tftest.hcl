# Output tests for Role Assignment module

mock_provider "azurerm" {
  mock_resource "azurerm_role_assignment" {
    defaults = {
      id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleAssignments/11111111-1111-1111-1111-111111111111"
      name               = "11111111-1111-1111-1111-111111111111"
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000000"
      role_definition_name = "Reader"
      principal_id       = "00000000-0000-0000-0000-000000000000"
      principal_type     = "ServicePrincipal"
      condition          = null
      condition_version  = null
      delegated_managed_identity_resource_id = null
    }
  }
}

variables {
  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg"
  role_definition_name = "Reader"
  principal_id         = "00000000-0000-0000-0000-000000000000"
  principal_type       = "ServicePrincipal"
}

run "verify_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleAssignments/11111111-1111-1111-1111-111111111111"
    error_message = "Output 'id' should return the role assignment ID."
  }

  assert {
    condition     = output.name == "11111111-1111-1111-1111-111111111111"
    error_message = "Output 'name' should return the role assignment name."
  }

  assert {
    condition     = output.scope == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg"
    error_message = "Output 'scope' should return the role assignment scope."
  }

  assert {
    condition     = output.role_definition_name == "Reader"
    error_message = "Output 'role_definition_name' should return the role definition name."
  }

  assert {
    condition     = output.principal_id == "00000000-0000-0000-0000-000000000000"
    error_message = "Output 'principal_id' should return the principal ID."
  }
}
