# Test default settings for Azure DevOps Team

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_team.team) == 0
    error_message = "No teams should be created by default."
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
