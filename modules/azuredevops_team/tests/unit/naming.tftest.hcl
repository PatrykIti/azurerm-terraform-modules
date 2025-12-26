# Test team administrator planning

mock_provider "azuredevops" {
  mock_resource "azuredevops_team" {
    defaults = {
      id         = "00000000-0000-0000-0000-000000000000"
      descriptor = "vssgp.Uy0xLTktMTIzNDU2Nzg5MA"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  teams = {
    admins = {
      name = "Admins Team"
    }
  }

  team_administrators = [
    {
      key               = "admins-admins"
      team_key          = "admins"
      admin_descriptors = ["vssgp.admin"]
      mode              = "add"
    }
  ]
}

run "team_administrator_plan" {
  command = plan

  assert {
    condition     = contains(keys(azuredevops_team_administrators.team_administrators), "admins-admins")
    error_message = "team_administrators should use the configured admin key."
  }
}
