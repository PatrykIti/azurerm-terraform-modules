# Test team naming and description values

mock_provider "azuredevops" {}

variables {
  project_id  = "00000000-0000-0000-0000-000000000000"
  name        = "Platform Team"
  description = "Platform engineering team"
}

run "team_name_passthrough" {
  command = plan

  assert {
    condition     = azuredevops_team.team.name == "Platform Team"
    error_message = "Team name should be passed through to the resource."
  }

  assert {
    condition     = azuredevops_team.team.description == "Platform engineering team"
    error_message = "Team description should be passed through to the resource."
  }
}
