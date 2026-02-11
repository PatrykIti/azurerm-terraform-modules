# Defaults tests for Role Assignment module

mock_provider "azurerm" {
  mock_resource "azurerm_role_assignment" {}
}

variables {
  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg"
  role_definition_name = "Reader"
  principal_id         = "00000000-0000-0000-0000-000000000000"
}

run "verify_defaults" {
  command = plan

  assert {
    condition     = var.name == null
    error_message = "name should default to null."
  }

  assert {
    condition     = var.description == null
    error_message = "description should default to null."
  }

  assert {
    condition     = var.condition == null
    error_message = "condition should default to null."
  }

  assert {
    condition     = var.condition_version == null
    error_message = "condition_version should default to null."
  }

  assert {
    condition     = var.delegated_managed_identity_resource_id == null
    error_message = "delegated_managed_identity_resource_id should default to null."
  }

  assert {
    condition     = var.principal_type == null
    error_message = "principal_type should default to null."
  }

  assert {
    condition     = var.skip_service_principal_aad_check == false
    error_message = "skip_service_principal_aad_check should default to false."
  }
}
