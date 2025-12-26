# Test variable validation for Azure DevOps Artifacts Feed

mock_provider "azuredevops" {}

run "invalid_feed_description" {
  command = plan

  variables {
    feeds = {
      example = {
        description = "  "
      }
    }
  }

  expect_failures = [
    var.feeds,
  ]
}

run "invalid_feed_project_id" {
  command = plan

  variables {
    feeds = {
      example = {
        project_id = "  "
      }
    }
  }

  expect_failures = [
    var.feeds,
  ]
}

run "invalid_feed_permission_selector" {
  command = plan

  variables {
    feeds = {
      example = {}
    }

    feed_permissions = [
      {
        feed_id             = "feed-0001"
        feed_key            = "example"
        identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
        role                = "reader"
      }
    ]
  }

  expect_failures = [
    var.feed_permissions,
  ]
}

run "invalid_feed_permission_feed_key" {
  command = plan

  variables {
    feeds = {
      example = {}
    }

    feed_permissions = [
      {
        feed_key            = "missing"
        identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
        role                = "reader"
      }
    ]
  }

  expect_failures = [
    var.feed_permissions,
  ]
}

run "invalid_feed_permission_role" {
  command = plan

  variables {
    feeds = {
      example = {}
    }

    feed_permissions = [
      {
        feed_key            = "example"
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
    feed_permissions = [
      {
        key                 = "dup"
        feed_id             = "feed-0001"
        identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
        role                = "reader"
      },
      {
        key                 = "dup"
        feed_id             = "feed-0002"
        identity_descriptor = "vssgp.Uy0xLTktNjU0MzIx"
        role                = "contributor"
      }
    ]
  }

  expect_failures = [
    var.feed_permissions,
  ]
}

run "invalid_retention_feed_key" {
  command = plan

  variables {
    feeds = {
      example = {}
    }

    feed_retention_policies = [
      {
        feed_key                                  = "missing"
        count_limit                               = 10
        days_to_keep_recently_downloaded_packages = 30
      }
    ]
  }

  expect_failures = [
    var.feed_retention_policies,
  ]
}

run "duplicate_retention_keys" {
  command = plan

  variables {
    feed_retention_policies = [
      {
        key                                       = "dup"
        feed_id                                   = "feed-0001"
        count_limit                               = 10
        days_to_keep_recently_downloaded_packages = 30
      },
      {
        key                                       = "dup"
        feed_id                                   = "feed-0002"
        count_limit                               = 5
        days_to_keep_recently_downloaded_packages = 7
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
    feed_retention_policies = [
      {
        feed_id                                   = "feed-0001"
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
    feed_retention_policies = [
      {
        feed_id                                   = "feed-0002"
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
    feeds = {
      example = {}
    }

    feed_permissions = [
      {
        key                 = "role-test"
        feed_key            = "example"
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
