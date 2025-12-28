# Test variable validation for Azure DevOps Repository

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "unit-repo"
}

run "missing_branch_repository_id_without_repo" {
  command = plan

  variables {
    name = null
    branches = [
      {
        name = "invalid"
      }
    ]
  }

  expect_failures = [
    var.branches,
  ]
}

run "duplicate_branch_keys" {
  command = plan

  variables {
    branches = [
      {
        name = "dev"
      },
      {
        name = "dev"
      }
    ]
  }

  expect_failures = [
    var.branches,
  ]
}

run "duplicate_file_keys" {
  command = plan

  variables {
    files = [
      {
        file    = "README.md"
        content = "a"
      },
      {
        file    = "README.md"
        content = "b"
      }
    ]
  }

  expect_failures = [
    var.files,
  ]
}

run "duplicate_git_permission_keys" {
  command = plan

  variables {
    git_permissions = [
      {
        principal = "group-1"
        permissions = {
          GenericRead = "Allow"
        }
      },
      {
        principal = "group-1"
        permissions = {
          GenericRead = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.git_permissions,
  ]
}

run "invalid_git_permission_value" {
  command = plan

  variables {
    git_permissions = [
      {
        principal = "group-2"
        permissions = {
          GenericRead = "Invalid"
        }
      }
    ]
  }

  expect_failures = [
    var.git_permissions,
  ]
}

run "invalid_repository_import_missing_source" {
  command = plan

  variables {
    initialization = {
      init_type             = "Import"
      service_connection_id = "00000000-0000-0000-0000-000000000000"
    }
  }

  expect_failures = [
    var.initialization,
  ]
}

run "invalid_repository_import_credentials" {
  command = plan

  variables {
    initialization = {
      init_type             = "Import"
      source_url            = "https://example.com/repo.git"
      service_connection_id = "00000000-0000-0000-0000-000000000000"
      username              = "user"
      password              = "password"
    }
  }

  expect_failures = [
    var.initialization,
  ]
}

run "invalid_min_reviewers" {
  command = plan

  variables {
    branch_policy_min_reviewers = [
      {
        reviewer_count = 0
        scope = [
          {
            match_type = "DefaultBranch"
          }
        ]
      }
    ]
  }

  expect_failures = [
    var.branch_policy_min_reviewers,
  ]
}

run "duplicate_policy_keys" {
  command = plan

  variables {
    branch_policy_min_reviewers = [
      {
        reviewer_count = 1
        scope = [
          {
            match_type = "DefaultBranch"
          }
        ]
      },
      {
        reviewer_count = 2
        scope = [
          {
            match_type = "DefaultBranch"
          }
        ]
      }
    ]
  }

  expect_failures = [
    var.branch_policy_min_reviewers,
  ]
}

run "invalid_match_type" {
  command = plan

  variables {
    branch_policy_status_check = [
      {
        name = "status"
        scope = [
          {
            match_type = "Invalid"
          }
        ]
      }
    ]
  }

  expect_failures = [
    var.branch_policy_status_check,
  ]
}

run "invalid_repository_ref_requirement" {
  command = plan

  variables {
    branch_policy_status_check = [
      {
        name = "status"
        scope = [
          {
            match_type = "Exact"
          }
        ]
      }
    ]
  }

  expect_failures = [
    var.branch_policy_status_check,
  ]
}

run "invalid_max_file_size" {
  command = plan

  variables {
    repository_policy_max_file_size = [
      {
        max_file_size = 0
      }
    ]
  }

  expect_failures = [
    var.repository_policy_max_file_size,
  ]
}

run "missing_repository_targets" {
  command = plan

  variables {
    name = null
    repository_policy_reserved_names = [
      {}
    ]
  }

  expect_failures = [
    var.repository_policy_reserved_names,
  ]
}
