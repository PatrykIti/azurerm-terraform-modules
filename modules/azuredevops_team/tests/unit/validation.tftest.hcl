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

run "unknown_team_member_key" {
  command = plan

  variables {
    team_members = [
      {
        team_key           = "missing"
        member_descriptors = ["vssgp.member"]
      }
    ]
  }

  expect_failures = [
    var.team_members,
  ]
}

run "duplicate_team_member_keys" {
  command = plan

  variables {
    team_members = [
      {
        key                = "duplicate"
        team_key           = "valid"
        member_descriptors = ["vssgp.member"]
      },
      {
        key                = "duplicate"
        team_key           = "valid"
        member_descriptors = ["vssgp.other"]
      }
    ]
  }

  expect_failures = [
    var.team_members,
  ]
}

run "team_member_mode_default" {
  command = plan

  variables {
    teams = {
      core = {
        name = "Core Team"
      }
    }

    team_members = [
      {
        key                = "core-members"
        team_key           = "core"
        member_descriptors = ["vssgp.member"]
      }
    ]
  }

  assert {
    condition     = azuredevops_team_members.team_members["core-members"].mode == "add"
    error_message = "team_members.mode should default to add."
  }
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

run "unknown_team_admin_key" {
  command = plan

  variables {
    team_administrators = [
      {
        team_key          = "missing"
        admin_descriptors = ["vssgp.admin"]
      }
    ]
  }

  expect_failures = [
    var.team_administrators,
  ]
}

run "duplicate_team_admin_keys" {
  command = plan

  variables {
    team_administrators = [
      {
        key               = "duplicate-admin"
        team_key          = "valid"
        admin_descriptors = ["vssgp.admin"]
      },
      {
        key               = "duplicate-admin"
        team_key          = "valid"
        admin_descriptors = ["vssgp.admin2"]
      }
    ]
  }

  expect_failures = [
    var.team_administrators,
  ]
}

run "invalid_team_name" {
  command = plan

  variables {
    teams = {
      " " = {
        name = " "
      }
    }
  }

  expect_failures = [
    var.teams,
  ]
}
