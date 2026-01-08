# Test defaults for Azure DevOps security role assignment

mock_provider "azuredevops" {
  mock_resource "azuredevops_securityrole_assignment" {
    defaults = {
      id = "assignment-0001"
    }
  }
}

run "missing_required_inputs" {
  command = plan

  # Expect the plan to fail due to missing required inputs
  expect_failures = [
    var.scope,
    var.resource_id,
    var.role_name,
    var.identity_id,
  ]

  variables {
    scope       = ""
    resource_id = ""
    role_name   = ""
    identity_id = ""
  }
}

run "creates_assignment" {
  command = apply

  variables {
    scope       = "project"
    resource_id = "00000000-0000-0000-0000-000000000000"
    role_name   = "Reader"
    identity_id = "11111111-1111-1111-1111-111111111111"
  }

  assert {
    condition     = azuredevops_securityrole_assignment.securityrole_assignment.id != ""
    error_message = "securityrole_assignment should be created when inputs are provided."
  }
}
