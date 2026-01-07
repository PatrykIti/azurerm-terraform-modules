# Test variable validation for Azure DevOps Identity

mock_provider "azuredevops" {}

run "missing_group_membership_members" {
  command = plan

  variables {
    group_display_name = "Valid Group"
    group_memberships = [
      {
        key                = "missing-group"
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

run "invalid_group_entitlement_selector" {
  command = plan

  variables {
    group_display_name = "Valid Group"

    group_entitlements = [
      {
        display_name = "AAD Group"
        origin       = "aad"
        origin_id    = "00000000-0000-0000-0000-000000000000"
      }
    ]
  }

  expect_failures = [
    var.group_entitlements,
  ]
}

run "duplicate_group_entitlement_keys" {
  command = plan

  variables {
    group_display_name = "Valid Group"

    group_entitlements = [
      {
        display_name = "AAD Group"
      },
      {
        display_name = "AAD Group"
      }
    ]
  }

  expect_failures = [
    var.group_entitlements,
  ]
}
