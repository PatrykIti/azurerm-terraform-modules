# Validation tests for Role Assignment module

mock_provider "azurerm" {
  mock_resource "azurerm_role_assignment" {}
}

variables {
  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg"
  role_definition_name = "Reader"
  principal_id         = "00000000-0000-0000-0000-000000000000"
}

run "missing_role_definition" {
  command = plan

  variables {
    role_definition_name = null
  }

  expect_failures = [
    var.role_definition_name
  ]
}

run "both_role_definition_values" {
  command = plan

  variables {
    role_definition_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000000"
    role_definition_name = "Reader"
  }

  expect_failures = [
    var.role_definition_name
  ]
}

run "condition_without_version" {
  command = plan

  variables {
    condition = "@Resource[Microsoft.Storage/storageAccounts:Name] StringEquals 'example'"
  }

  expect_failures = [
    var.condition_version
  ]
}

run "version_without_condition" {
  command = plan

  variables {
    condition_version = "2.0"
  }

  expect_failures = [
    var.condition_version
  ]
}

run "invalid_principal_type" {
  command = plan

  variables {
    principal_type = "InvalidType"
  }

  expect_failures = [
    var.principal_type
  ]
}

run "skip_aad_check_wrong_principal_type" {
  command = plan

  variables {
    principal_type                   = "User"
    skip_service_principal_aad_check = true
  }

  expect_failures = [
    var.skip_service_principal_aad_check
  ]
}

run "delegated_identity_wrong_principal_type" {
  command = plan

  variables {
    principal_type                         = "User"
    delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example"
  }

  expect_failures = [
    var.delegated_managed_identity_resource_id
  ]
}
