# Test outputs for Azure DevOps Group

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
  group_display_name = "Admins"

  group_memberships = [
    {
      key                = "admin-membership"
      member_descriptors = ["vssgp.member"]
      mode               = "add"
    }
  ]
}

run "outputs_plan" {
  command = apply

  assert {
    condition     = output.group_id != null
    error_message = "group_id should be present when the module group is configured."
  }

  assert {
    condition     = output.group_descriptor != null
    error_message = "group_descriptor should be present when the module group is configured."
  }

  assert {
    condition     = length(keys(output.group_membership_ids)) == 1
    error_message = "group_membership_ids should include memberships."
  }

  assert {
    condition     = contains(keys(output.group_membership_ids), "admin-membership")
    error_message = "group_membership_ids should be keyed by membership key."
  }
}
