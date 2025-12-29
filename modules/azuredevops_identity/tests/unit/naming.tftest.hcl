# Test security role assignment planning

mock_provider "azuredevops" {
  mock_resource "azuredevops_group" {
    defaults = {
      group_id   = "00000000-0000-0000-0000-000000000000"
      descriptor = "vssgp.Uy0xLTktMTIzNDU2Nzg5MA"
    }
  }
}

variables {
  group_display_name = "Operators"

  securityrole_assignments = [
    {
      key         = "operators-reader"
      scope       = "project"
      resource_id = "11111111-1111-1111-1111-111111111111"
      role_name   = "Reader"
    }
  ]
}

run "security_role_assignment_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_securityrole_assignment.securityrole_assignment) == 1
    error_message = "securityrole_assignments should create a role assignment."
  }

  assert {
    condition     = contains(keys(azuredevops_securityrole_assignment.securityrole_assignment), "operators-reader")
    error_message = "securityrole_assignments should be keyed by assignment key."
  }
}
