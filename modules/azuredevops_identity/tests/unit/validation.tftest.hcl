# Test variable validation for Azure DevOps Identity

mock_provider "azuredevops" {}

variables {
  groups = {
    valid = {
      display_name = "Valid Group"
    }
  }
}

run "invalid_group_membership_selector" {
  command = plan

  variables {
    group_memberships = [
      {
        group_descriptor   = "vssgp.invalid"
        group_key          = "valid"
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
    group_memberships = [
      {
        group_key = "valid"
      }
    ]
  }

  expect_failures = [
    var.group_memberships,
  ]
}

run "invalid_group_entitlement_license" {
  command = plan

  variables {
    group_entitlements = [
      {
        display_name         = "AAD Group"
        account_license_type = "invalid"
      }
    ]
  }

  expect_failures = [
    var.group_entitlements,
  ]
}

run "invalid_user_entitlement_source" {
  command = plan

  variables {
    user_entitlements = [
      {
        principal_name   = "user@example.com"
        licensing_source = "invalid"
      }
    ]
  }

  expect_failures = [
    var.user_entitlements,
  ]
}

run "invalid_security_role_assignment_identity" {
  command = plan

  variables {
    securityrole_assignments = [
      {
        scope              = "project"
        resource_id        = "11111111-1111-1111-1111-111111111111"
        role_name          = "Reader"
        identity_id        = "id"
        identity_group_key = "valid"
      }
    ]
  }

  expect_failures = [
    var.securityrole_assignments,
  ]
}
