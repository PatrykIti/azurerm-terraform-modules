# Test default settings for Azure DevOps Team

mock_provider "azuredevops" {
  mock_resource "azuredevops_team" {
    defaults = {
      id         = "00000000-0000-0000-0000-000000000000"
      descriptor = "vssgp.Uy0xLTktMTIzNDU2Nzg5MA"
    }
    override_during = plan
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "Core Team"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = azuredevops_team.team.name == "Core Team"
    error_message = "Team name should match the input."
  }

  assert {
    condition     = length(azuredevops_team_members.team_members) == 0
    error_message = "No team memberships should be created by default."
  }

  assert {
    condition     = length(azuredevops_team_administrators.team_administrators) == 0
    error_message = "No team administrators should be created by default."
  }
}
