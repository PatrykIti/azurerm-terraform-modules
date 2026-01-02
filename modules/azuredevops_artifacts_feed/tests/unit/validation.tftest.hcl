# Test variable validation for Azure DevOps Artifacts Feed

mock_provider "azuredevops" {
  mock_resource "azuredevops_feed" {
    defaults = {
      id         = "11111111-1111-1111-1111-111111111111"
      name       = "example-feed"
      project_id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

run "missing_name" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"
  }

  expect_failures = [
    var.name,
  ]
}

run "missing_project_id" {
  command = plan

  variables {
    name = "example-feed"
  }

  expect_failures = [
    var.project_id,
  ]
}

run "invalid_description" {
  command = plan

  variables {
    name        = "example-feed"
    project_id  = "00000000-0000-0000-0000-000000000000"
    description = ""
  }

  expect_failures = [
    var.description,
  ]
}

run "invalid_feed_permission_role" {
  command = plan

  variables {
    name       = "example-feed"
    project_id = "00000000-0000-0000-0000-000000000000"

    feed_permissions = [
      {
        key                 = "invalid-role"
        identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
        role                = "owner"
      }
    ]
  }

  expect_failures = [
    var.feed_permissions,
  ]
}

run "duplicate_feed_permission_keys" {
  command = plan

  variables {
    name       = "example-feed"
    project_id = "00000000-0000-0000-0000-000000000000"

    feed_permissions = [
      {
        key                 = "dup"
        identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
        role                = "reader"
      },
      {
        key                 = "dup"
        identity_descriptor = "vssgp.Uy0xLTktNjU0MzIx"
        role                = "contributor"
      }
    ]
  }

  expect_failures = [
    var.feed_permissions,
  ]
}

run "duplicate_retention_keys" {
  command = plan

  variables {
    name       = "example-feed"
    project_id = "00000000-0000-0000-0000-000000000000"

    feed_retention_policies = [
      {
        count_limit                               = 10
        days_to_keep_recently_downloaded_packages = 30
      },
      {
        count_limit                               = 10
        days_to_keep_recently_downloaded_packages = 30
      }
    ]
  }

  expect_failures = [
    var.feed_retention_policies,
  ]
}

run "invalid_retention_limits" {
  command = plan

  variables {
    name       = "example-feed"
    project_id = "00000000-0000-0000-0000-000000000000"

    feed_retention_policies = [
      {
        count_limit                               = 0
        days_to_keep_recently_downloaded_packages = 1
      }
    ]
  }

  expect_failures = [
    var.feed_retention_policies,
  ]
}

run "invalid_retention_days" {
  command = plan

  variables {
    name       = "example-feed"
    project_id = "00000000-0000-0000-0000-000000000000"

    feed_retention_policies = [
      {
        count_limit                               = 5
        days_to_keep_recently_downloaded_packages = 0
      }
    ]
  }

  expect_failures = [
    var.feed_retention_policies,
  ]
}

run "role_normalization" {
  command = plan

  variables {
    name       = "example-feed"
    project_id = "00000000-0000-0000-0000-000000000000"

    feed_permissions = [
      {
        key                 = "role-test"
        identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
        role                = "ReAdEr"
      }
    ]
  }

  assert {
    condition     = azuredevops_feed_permission.feed_permission["role-test"].role == "reader"
    error_message = "feed_permissions.role should be normalized to lowercase."
  }
}

run "feed_permission_attaches_to_module_feed" {
  command = apply

  variables {
    name       = "example-feed"
    project_id = "00000000-0000-0000-0000-000000000000"

    feed_permissions = [
      {
        key                 = "default-feed"
        identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
        role                = "reader"
      }
    ]
  }

  assert {
    condition     = azuredevops_feed_permission.feed_permission["default-feed"].feed_id == "11111111-1111-1111-1111-111111111111"
    error_message = "feed_permissions should attach to the module feed."
  }

  assert {
    condition     = azuredevops_feed_permission.feed_permission["default-feed"].project_id == "00000000-0000-0000-0000-000000000000"
    error_message = "feed_permissions should use the module project_id."
  }
}

run "feed_retention_attaches_to_module_feed" {
  command = apply

  variables {
    name       = "example-feed"
    project_id = "00000000-0000-0000-0000-000000000000"

    feed_retention_policies = [
      {
        key                                       = "default-retention"
        count_limit                               = 10
        days_to_keep_recently_downloaded_packages = 30
      }
    ]
  }

  assert {
    condition     = azuredevops_feed_retention_policy.feed_retention_policy["default-retention"].feed_id == "11111111-1111-1111-1111-111111111111"
    error_message = "feed_retention_policies should attach to the module feed."
  }

  assert {
    condition     = azuredevops_feed_retention_policy.feed_retention_policy["default-retention"].project_id == "00000000-0000-0000-0000-000000000000"
    error_message = "feed_retention_policies should use the module project_id."
  }
}
