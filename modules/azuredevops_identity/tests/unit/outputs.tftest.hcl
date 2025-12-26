# Test outputs for Azure DevOps Identity

mock_provider "azuredevops" {
  mock_resource "azuredevops_group" {
    defaults = {
      group_id   = "00000000-0000-0000-0000-000000000000"
      descriptor = "vssgp.Uy0xLTktMTIzNDU2Nzg5MA"
    }
  }

  mock_resource "azuredevops_group_membership" {
    defaults = {
      id = "membership-0001"
    }
  }
}

variables {
  groups = {
    admins = {
      display_name = "Admins"
    }
    developers = {
      display_name = "Developers"
    }
  }

  group_memberships = [
    {
      key               = "admin-membership"
      group_key         = "admins"
      member_group_keys = ["developers"]
      mode              = "add"
    }
  ]

  securityrole_assignments = [
    {
      key                = "admins-reader"
      scope              = "project"
      resource_id        = "11111111-1111-1111-1111-111111111111"
      role_name          = "Reader"
      identity_group_key = "admins"
    }
  ]
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = length(keys(output.group_ids)) == 2
    error_message = "group_ids should include all configured groups."
  }

  assert {
    condition     = length(keys(output.group_descriptors)) == 2
    error_message = "group_descriptors should include all configured groups."
  }

  assert {
    condition     = length(keys(output.group_membership_ids)) == 1
    error_message = "group_membership_ids should include memberships."
  }

  assert {
    condition     = contains(keys(output.group_membership_ids), "admin-membership")
    error_message = "group_membership_ids should be keyed by membership key."
  }

  assert {
    condition     = contains(keys(output.securityrole_assignment_ids), "admins-reader")
    error_message = "securityrole_assignment_ids should be keyed by assignment key."
  }
}
