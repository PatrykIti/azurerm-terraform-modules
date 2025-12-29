# Test variable validation for Azure DevOps Team

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

run "invalid_team_name" {
  command = plan

  variables {
    name = " "
  }

  expect_failures = [
    var.name,
  ]
}

run "missing_team_member_key" {
  command = plan

  variables {
    team_members = [
      {
        member_descriptors = ["vssgp.member"]
      }
    ]
  }

  expect_failures = [
    var.team_members,
  ]
}

run "empty_team_member_team_id" {
  command = plan

  variables {
    team_members = [
      {
        key                = "members"
        team_id            = " "
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
        member_descriptors = ["vssgp.member"]
      },
      {
        key                = "duplicate"
        member_descriptors = ["vssgp.other"]
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
        key                = "members"
        member_descriptors = ["vssgp.member"]
        mode               = "replace"
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
    team_members = [
      {
        key                = "members"
        member_descriptors = ["vssgp.member"]
      }
    ]
  }

  assert {
    condition     = azuredevops_team_members.team_members["members"].mode == "add"
    error_message = "team_members.mode should default to add."
  }
}

run "team_member_team_id_default" {
  command = plan

  variables {
    team_members = [
      {
        key                = "members"
        member_descriptors = ["vssgp.member"]
      }
    ]
  }

  assert {
    condition     = azuredevops_team_members.team_members["members"].team_id == azuredevops_team.team.id
    error_message = "team_members.team_id should default to the module team ID."
  }
}

run "missing_team_admin_key" {
  command = plan

  variables {
    team_administrators = [
      {
        admin_descriptors = ["vssgp.admin"]
      }
    ]
  }

  expect_failures = [
    var.team_administrators,
  ]
}

run "empty_team_admin_team_id" {
  command = plan

  variables {
    team_administrators = [
      {
        key               = "admins"
        team_id           = " "
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
        admin_descriptors = ["vssgp.admin"]
      },
      {
        key               = "duplicate-admin"
        admin_descriptors = ["vssgp.admin2"]
      }
    ]
  }

  expect_failures = [
    var.team_administrators,
  ]
}

run "invalid_team_admin_mode" {
  command = plan

  variables {
    team_administrators = [
      {
        key               = "admins"
        admin_descriptors = ["vssgp.admin"]
        mode              = "replace"
      }
    ]
  }

  expect_failures = [
    var.team_administrators,
  ]
}

run "team_admin_mode_default" {
  command = plan

  variables {
    team_administrators = [
      {
        key               = "admins"
        admin_descriptors = ["vssgp.admin"]
      }
    ]
  }

  assert {
    condition     = azuredevops_team_administrators.team_administrators["admins"].mode == "add"
    error_message = "team_administrators.mode should default to add."
  }
}
