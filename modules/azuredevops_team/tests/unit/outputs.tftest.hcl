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

  teams = {
    core = {
      name = "Core Team"
    }
    platform = {
      name = "Platform Team"
    }
  }

  team_members = [
    {
      key                = "core-members"
      team_key           = "core"
      member_descriptors = ["vssgp.member"]
      mode               = "add"
    }
  ]

  team_administrators = [
    {
      key               = "core-admins"
      team_key          = "core"
      admin_descriptors = ["vssgp.admin"]
      mode              = "add"
    }
  ]
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = length(keys(output.team_ids)) == 2
    error_message = "team_ids should include all configured teams."
  }

  assert {
    condition     = length(keys(output.team_descriptors)) == 2
    error_message = "team_descriptors should include all configured teams."
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
