# Test default settings for Azure DevOps Group

mock_provider "azuredevops" {
  mock_resource "azuredevops_group" {
    defaults = {
      group_id   = "00000000-0000-0000-0000-000000000000"
      descriptor = "vssgp.mock"
    }
  }
}

run "default_membership_mode" {
  command = plan

  variables {
    group_display_name = "Admins"

    group_memberships = [
      {
        key                = "default-mode"
        member_descriptors = ["vssgp.member"]
      }
    ]
  }

  assert {
    condition     = azuredevops_group_membership.group_membership["default-mode"].mode == "add"
    error_message = "group_memberships.mode should default to add."
  }
}

run "group_required" {
  command = plan

  variables {
    group_display_name = ""
  }

  expect_failures = [
    var.group_display_name,
  ]
}
