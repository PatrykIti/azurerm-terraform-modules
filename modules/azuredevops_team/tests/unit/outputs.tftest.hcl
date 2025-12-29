# Test outputs for Azure DevOps Team

mock_provider "azuredevops" {
  mock_resource "azuredevops_team" {
    defaults = {
      id         = "00000000-0000-0000-0000-000000000000"
      descriptor = "vssgp.Uy0xLTktMTIzNDU2Nzg5MA"
    }
    override_during = plan
  }

  mock_resource "azuredevops_team_members" {
    defaults = {
      id = "team-membership-0001"
    }
    override_during = plan
  }

  mock_resource "azuredevops_team_administrators" {
    defaults = {
      id = "team-admins-0001"
    }
    override_during = plan
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "Core Team"

  team_members = [
    {
      key                = "core-members"
      member_descriptors = ["vssgp.member"]
      mode               = "add"
    }
  ]

  team_administrators = [
    {
      key               = "core-admins"
      admin_descriptors = ["vssgp.admin"]
      mode              = "add"
    }
  ]
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = output.team_id == "00000000-0000-0000-0000-000000000000"
    error_message = "team_id should match the mocked team ID."
  }

  assert {
    condition     = output.team_descriptor == "vssgp.Uy0xLTktMTIzNDU2Nzg5MA"
    error_message = "team_descriptor should match the mocked descriptor."
  }

  assert {
    condition     = contains(keys(output.team_member_ids), "core-members")
    error_message = "team_member_ids should be keyed by the membership key."
  }

  assert {
    condition     = contains(keys(output.team_administrator_ids), "core-admins")
    error_message = "team_administrator_ids should be keyed by the admin key."
  }
}
