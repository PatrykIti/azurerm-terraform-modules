# Test defaults for Azure DevOps security role assignments

mock_provider "azuredevops" {
  mock_resource "azuredevops_securityrole_assignment" {
    defaults = {
      id = "assignment-0001"
    }
  }
}

run "no_assignments_by_default" {
  command = plan

  assert {
    condition     = length(azuredevops_securityrole_assignment.securityrole_assignment) == 0
    error_message = "No security role assignments should be created by default."
  }
}

run "assignment_keys" {
  command = apply

  variables {
    securityrole_assignments = [
      {
        key         = "reader"
        scope       = "project"
        resource_id = "00000000-0000-0000-0000-000000000000"
        role_name   = "Reader"
        identity_id = "11111111-1111-1111-1111-111111111111"
      }
    ]
  }

  assert {
    condition     = contains(keys(azuredevops_securityrole_assignment.securityrole_assignment), "reader")
    error_message = "securityrole_assignments should be keyed by the provided key."
  }
}
