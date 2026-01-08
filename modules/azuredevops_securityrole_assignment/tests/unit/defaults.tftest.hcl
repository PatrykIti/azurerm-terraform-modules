# Test defaults for Azure DevOps security role assignment

mock_provider "azuredevops" {
  mock_resource "azuredevops_securityrole_assignment" {
    defaults = {
      id = "assignment-0001"
    }
  }
}

run "missing_scope" {
  command = plan

  expect_failures = [
    var.scope,
  ]

  variables {
    scope       = ""
    resource_id = "00000000-0000-0000-0000-000000000000"
    role_name   = "Reader"
    identity_id = "11111111-1111-1111-1111-111111111111"
  }
}

run "missing_resource_id" {
  command = plan

  expect_failures = [
    var.resource_id,
  ]

  variables {
    scope       = "00000000-0000-0000-0000-000000000000"
    resource_id = ""
    role_name   = "Reader"
    identity_id = "11111111-1111-1111-1111-111111111111"
  }
}

run "missing_role_name" {
  command = plan

  expect_failures = [
    var.role_name,
  ]

  variables {
    scope       = "00000000-0000-0000-0000-000000000000"
    resource_id = "00000000-0000-0000-0000-000000000000"
    role_name   = ""
    identity_id = "11111111-1111-1111-1111-111111111111"
  }
}

run "creates_assignment" {
  command = apply

  variables {
    scope       = "00000000-0000-0000-0000-000000000000"
    resource_id = "00000000-0000-0000-0000-000000000000"
    role_name   = "Reader"
    identity_id = "11111111-1111-1111-1111-111111111111"
  }

  assert {
    condition     = azuredevops_securityrole_assignment.securityrole_assignment.id != ""
    error_message = "securityrole_assignment should be created when inputs are provided."
  }
}
