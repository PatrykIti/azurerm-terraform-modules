# Test variable validation for Azure DevOps Team

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  teams = {
    valid = {
      name = "Valid Team"
    }
  }
}

run "invalid_team_member_selector" {
  command = plan

  variables {
    team_members = [
      {
        team_id            = "00000000-0000-0000-0000-000000000000"
        team_key           = "valid"
        member_descriptors = ["vssgp.member"]
      }
    ]
  }

  expect_failures = [
    var.team_members,
  ]
}

run "missing_team_member_descriptors" {
  command = plan

  variables {
    team_members = [
      {
        team_key           = "valid"
        member_descriptors = []
      }
    ]
  }

  expect_failures = [
    var.team_members,
  ]
}

run "invalid_team_member_mode" {
  command = plan

  variables {
    team_members = [
      {
        team_key           = "valid"
        member_descriptors = ["vssgp.member"]
        mode               = "replace"
      }
    ]
  }

  expect_failures = [
    var.team_members,
  ]
}

run "invalid_team_admin_selector" {
  command = plan

  variables {
    team_administrators = [
      {
        team_id           = "00000000-0000-0000-0000-000000000000"
        team_key          = "valid"
        admin_descriptors = ["vssgp.admin"]
      }
    ]
  }

  expect_failures = [
    var.team_administrators,
  ]
}
