# Test variable validation for Azure DevOps Repository

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  repositories = {
    main = {}
  }
}

run "invalid_branch_selector" {
  command = plan

  variables {
    branches = [
      {
        repository_id  = "00000000-0000-0000-0000-000000000000"
        repository_key = "main"
        name           = "invalid"
      }
    ]
  }

  expect_failures = [
    var.branches,
  ]
}

run "invalid_branch_repository_key" {
  command = plan

  variables {
    branches = [
      {
        repository_key = "missing"
        name           = "invalid"
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
        repository_key = "main"
        name           = "dev"
      },
      {
        repository_key = "main"
        name           = "dev"
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
        repository_key = "main"
        file           = "README.md"
        content        = "a"
      },
      {
        repository_key = "main"
        file           = "README.md"
        content        = "b"
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
        repository_key = "main"
        principal      = "group-1"
        permissions = {
          GenericRead = "Allow"
        }
      },
      {
        repository_key = "main"
        principal      = "group-1"
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
        repository_key = "main"
        principal      = "group-2"
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

run "invalid_repository_import" {
  command = plan

  variables {
    repositories = {
      main = {
        initialization = {
          init_type             = "Import"
          service_connection_id = "00000000-0000-0000-0000-000000000000"
        }
      }
    }
  }

  expect_failures = [
    var.repositories,
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
            repository_key = "main"
            match_type     = "DefaultBranch"
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
            repository_key = "main"
            match_type     = "DefaultBranch"
          }
        ]
      },
      {
        reviewer_count = 2
        scope = [
          {
            repository_key = "main"
            match_type     = "DefaultBranch"
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
            repository_key = "main"
            match_type     = "Invalid"
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
        max_file_size   = 0
        repository_keys = ["main"]
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
    repository_policy_reserved_names = [
      {}
    ]
  }

  expect_failures = [
    var.repository_policy_reserved_names,
  ]
}
