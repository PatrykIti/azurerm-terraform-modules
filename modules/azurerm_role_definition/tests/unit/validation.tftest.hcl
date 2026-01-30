# Validation tests for Role Definition module

mock_provider "azurerm" {
  mock_resource "azurerm_role_definition" {}
}

variables {
  name  = "custom-role-validation"
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

run "empty_permissions" {
  command = plan

  variables {
    permissions = []
  }

  expect_failures = [
    var.permissions
  ]
}

run "permissions_missing_actions" {
  command = plan

  variables {
    permissions = [
      {
        actions      = []
        data_actions = []
      }
    ]
  }

  expect_failures = [
    var.permissions
  ]
}

run "empty_assignable_scopes" {
  command = plan

  variables {
    assignable_scopes = []
  }

  expect_failures = [
    var.assignable_scopes
  ]
}

run "assignable_scope_outside_scope" {
  command = plan

  variables {
    scope = "/subscriptions/00000000-0000-0000-0000-000000000000"
    assignable_scopes = [
      "/subscriptions/11111111-1111-1111-1111-111111111111"
    ]
  }

  expect_failures = [
    azurerm_role_definition.role_definition
  ]
}

run "data_actions_with_management_group_scope" {
  command = plan

  variables {
    scope = "/providers/Microsoft.Management/managementGroups/test-mg"
    assignable_scopes = [
      "/providers/Microsoft.Management/managementGroups/test-mg"
    ]
    permissions = [
      {
        actions = [
          "Microsoft.Resources/subscriptions/resourceGroups/read"
        ]
        data_actions = [
          "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"
        ]
      }
    ]
  }

  expect_failures = [
    azurerm_role_definition.role_definition
  ]
}
