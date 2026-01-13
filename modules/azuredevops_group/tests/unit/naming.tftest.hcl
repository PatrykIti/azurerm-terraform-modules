# Test group membership planning

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

  group_memberships = [
    {
      key                = "operators-membership"
      member_descriptors = ["vssgp.member"]
      mode               = "add"
    }
  ]
}

run "group_membership_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_group_membership.group_membership) == 1
    error_message = "group_memberships should create a membership."
  }

  assert {
    condition     = contains(keys(azuredevops_group_membership.group_membership), "operators-membership")
    error_message = "group_memberships should be keyed by membership key."
  }
}
