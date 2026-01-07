# Validation tests for security role assignments

mock_provider "azuredevops" {}

run "duplicate_keys" {
  command = plan

  variables {
    securityrole_assignments = [
      {
        key         = "dup"
        scope       = "project"
        resource_id = "00000000-0000-0000-0000-000000000000"
        role_name   = "Reader"
        identity_id = "11111111-1111-1111-1111-111111111111"
      },
      {
        key         = "dup"
        scope       = "project"
        resource_id = "00000000-0000-0000-0000-000000000000"
        role_name   = "Reader"
        identity_id = "22222222-2222-2222-2222-222222222222"
      }
    ]
  }

  expect_failures = [
    var.securityrole_assignments,
  ]
}

run "missing_identity" {
  command = plan

  variables {
    securityrole_assignments = [
      {
        key         = "missing-id"
        scope       = "project"
        resource_id = "00000000-0000-0000-0000-000000000000"
        role_name   = "Reader"
        identity_id = ""
      }
    ]
  }

  expect_failures = [
    var.securityrole_assignments,
  ]
}
