# Test variable validation for Azure DevOps Project Permissions

mock_provider "azuredevops" {
  mock_resource "azuredevops_project_permissions" {}

  mock_data "azuredevops_group" {
    defaults = {
      id = "vssgp.readers"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "empty_project_id" {
  command = plan

  variables {
    project_id = ""
  }

  expect_failures = [
    var.project_id,
  ]
}

run "missing_principal_and_group" {
  command = plan

  variables {
    permissions = [
      {
        permissions = {
          GENERIC_READ = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.permissions,
  ]
}

run "missing_scope" {
  command = plan

  variables {
    permissions = [
      {
        group_name = "Readers"
        permissions = {
          GENERIC_READ = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.permissions,
  ]
}

run "invalid_scope" {
  command = plan

  variables {
    permissions = [
      {
        group_name = "Readers"
        scope      = "team"
        permissions = {
          GENERIC_READ = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.permissions,
  ]
}

run "invalid_permission_value" {
  command = plan

  variables {
    permissions = [
      {
        principal = "vssgp.readers"
        permissions = {
          GENERIC_READ = "Maybe"
        }
      }
    ]
  }

  expect_failures = [
    var.permissions,
  ]
}

run "duplicate_keys" {
  command = plan

  variables {
    permissions = [
      {
        key       = "dup"
        principal = "vssgp.one"
        permissions = {
          GENERIC_READ = "Allow"
        }
      },
      {
        key       = "dup"
        principal = "vssgp.two"
        permissions = {
          GENERIC_READ = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.permissions,
  ]
}
