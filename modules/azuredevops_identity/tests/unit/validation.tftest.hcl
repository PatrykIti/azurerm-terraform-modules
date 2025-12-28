# Test variable validation for Azure DevOps Identity

mock_provider "azuredevops" {}

run "missing_group_membership_group_descriptor_without_group" {
  command = plan

  variables {
    group_memberships = [
      {
        key                = "missing-group"
        member_descriptors = ["vssgp.member"]
      }
    ]
  }

  expect_failures = [
    var.group_memberships,
  ]
}

run "missing_group_membership_members" {
  command = plan

  variables {
    group_display_name = "Valid Group"

    group_memberships = [
      {
        key = "missing-members"
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

run "invalid_user_entitlement_selector" {
  command = plan

  variables {
    user_entitlements = [
      {
        principal_name = "user@example.com"
        origin_id      = "00000000-0000-0000-0000-000000000000"
        origin         = "aad"
      }
    ]
  }

  expect_failures = [
    var.user_entitlements,
  ]
}

run "duplicate_user_entitlement_keys" {
  command = plan

  variables {
    user_entitlements = [
      {
        principal_name = "user@example.com"
      },
      {
        principal_name = "user@example.com"
      }
    ]
  }

  expect_failures = [
    var.user_entitlements,
  ]
}

run "duplicate_service_principal_entitlement_keys" {
  command = plan

  variables {
    service_principal_entitlements = [
      {
        origin_id = "00000000-0000-0000-0000-000000000000"
      },
      {
        origin_id = "00000000-0000-0000-0000-000000000000"
      }
    ]
  }

  expect_failures = [
    var.service_principal_entitlements,
  ]
}

run "missing_security_role_assignment_identity_without_group" {
  command = plan

  variables {
    securityrole_assignments = [
      {
        scope       = "project"
        resource_id = "11111111-1111-1111-1111-111111111111"
        role_name   = "Reader"
      }
    ]
  }

  expect_failures = [
    var.securityrole_assignments,
  ]
}

run "duplicate_security_role_assignment_keys" {
  command = plan

  variables {
    securityrole_assignments = [
      {
        key         = "duplicate"
        scope       = "project"
        resource_id = "11111111-1111-1111-1111-111111111111"
        role_name   = "Reader"
        identity_id = "id"
      },
      {
        key         = "duplicate"
        scope       = "project"
        resource_id = "22222222-2222-2222-2222-222222222222"
        role_name   = "Reader"
        identity_id = "id-2"
      }
    ]
  }

  expect_failures = [
    var.securityrole_assignments,
  ]
}
