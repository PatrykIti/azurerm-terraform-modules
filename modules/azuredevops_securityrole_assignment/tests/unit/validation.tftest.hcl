# Validation tests for security role assignments

mock_provider "azuredevops" {}

run "missing_identity" {
  command = plan

  variables {
    scope       = "00000000-0000-0000-0000-000000000000"
    resource_id = "00000000-0000-0000-0000-000000000000"
    role_name   = "Reader"
    identity_id = ""
  }

  expect_failures = [
    var.identity_id,
  ]
}

run "invalid_role_name" {
  command = plan

  variables {
    scope       = "00000000-0000-0000-0000-000000000000"
    resource_id = "00000000-0000-0000-0000-000000000000"
    role_name   = "Contributor"
    identity_id = "11111111-1111-1111-1111-111111111111"
  }

  expect_failures = [
    var.role_name,
  ]
}

run "creator_requires_library_scope" {
  command = plan

  variables {
    scope       = "distributedtask.globalagentpoolrole"
    resource_id = "00000000-0000-0000-0000-000000000000"
    role_name   = "Creator"
    identity_id = "11111111-1111-1111-1111-111111111111"
  }

  expect_failures = [
    var.role_name,
  ]
}

run "creator_allowed_for_library_scope" {
  command = plan

  variables {
    scope       = "distributedtask.library"
    resource_id = "00000000-0000-0000-0000-000000000000"
    role_name   = "Creator"
    identity_id = "11111111-1111-1111-1111-111111111111"
  }
}
