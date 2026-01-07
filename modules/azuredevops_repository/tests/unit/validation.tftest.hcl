# Test variable validation for Azure DevOps Repository

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "unit-repo"
  initialization = {}
}

run "duplicate_branch_names" {
  command = plan

  variables {
    branches = [
      {
        name       = "dev"
        ref_branch = "refs/heads/main"
      },
      {
        name       = "dev"
        ref_branch = "refs/heads/main"
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
    branches = [
      {
        name       = "main"
        ref_branch = "refs/heads/main"
        policies = {
          min_reviewers = {
            reviewer_count = 0
          }
        }
      }
    ]
  }

  expect_failures = [
    var.branches,
  ]
}

run "duplicate_build_validation_names" {
  command = plan

  variables {
    branches = [
      {
        name       = "main"
        ref_branch = "refs/heads/main"
        policies = {
          build_validation = [
            {
              name                = "ci"
              build_definition_id = "1"
              display_name        = "CI"
            },
            {
              name                = "ci"
              build_definition_id = "2"
              display_name        = "CI2"
            }
          ]
        }
      }
    ]
  }

  expect_failures = [
    var.branches,
  ]
}

run "duplicate_build_validation_names_across_branches" {
  command = plan

  variables {
    branches = [
      {
        name       = "main"
        ref_branch = "refs/heads/main"
        policies = {
          build_validation = [
            {
              name                = "ci"
              build_definition_id = "1"
              display_name        = "CI"
            }
          ]
        }
      },
      {
        name       = "develop"
        ref_branch = "refs/heads/main"
        policies = {
          build_validation = [
            {
              name                = "ci"
              build_definition_id = "2"
              display_name        = "CI2"
            }
          ]
        }
      }
    ]
  }

  expect_failures = [
    var.branches,
  ]
}

run "invalid_build_validation_display_name" {
  command = plan

  variables {
    branches = [
      {
        name       = "main"
        ref_branch = "refs/heads/main"
        policies = {
          build_validation = [
            {
              name                = "ci"
              build_definition_id = "1"
              display_name        = ""
            }
          ]
        }
      }
    ]
  }

  expect_failures = [
    var.branches,
  ]
}

run "invalid_status_check_name" {
  command = plan

  variables {
    branches = [
      {
        name       = "main"
        ref_branch = "refs/heads/main"
        policies = {
          status_check = [
            {
              name = ""
            }
          ]
        }
      }
    ]
  }

  expect_failures = [
    var.branches,
  ]
}

run "invalid_auto_reviewer_ids" {
  command = plan

  variables {
    branches = [
      {
        name       = "main"
        ref_branch = "refs/heads/main"
        policies = {
          auto_reviewers = [
            {
              name              = "auto"
              auto_reviewer_ids = []
            }
          ]
        }
      }
    ]
  }

  expect_failures = [
    var.branches,
  ]
}

run "invalid_max_file_size" {
  command = plan

  variables {
    policies = {
      maximum_file_size = {
        max_file_size = 0
      }
    }
  }

  expect_failures = [
    var.policies,
  ]
}
