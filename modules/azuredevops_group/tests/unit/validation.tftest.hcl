# Test variable validation for Azure DevOps Group

mock_provider "azuredevops" {}

run "missing_group_membership_members" {
  command = plan

  variables {
    group_display_name = "Valid Group"
    group_memberships = [
      {
        key                = "missing-members"
        member_descriptors = []
      }
    ]
  }

  expect_failures = [
    var.group_memberships,
  ]
}

run "missing_group_membership_key" {
  command = plan

  variables {
    group_display_name = "Valid Group"

    group_memberships = [
      {
        key                = ""
        member_descriptors = ["vssgp.member"]
      }
    ]
  }

  expect_failures = [
    var.group_memberships,
  ]
}

run "invalid_group_membership_mode" {
  command = plan

  variables {
    group_display_name = "Valid Group"

    group_memberships = [
      {
        key                = "invalid-mode"
        member_descriptors = ["vssgp.member"]
        mode               = "remove"
      }
    ]
  }

  expect_failures = [
    var.group_memberships,
  ]
}

run "duplicate_group_membership_keys" {
  command = plan

  variables {
    group_display_name = "Valid Group"

    group_memberships = [
      {
        key                = "duplicate"
        member_descriptors = ["vssgp.member"]
      },
      {
        key                = "duplicate"
        member_descriptors = ["vssgp.member-2"]
      }
    ]
  }

  expect_failures = [
    var.group_memberships,
  ]
}
