# Test variable validation for the Azure DevOps Project module

mock_provider "azuredevops" {
  mock_resource "azuredevops_project" {
    defaults = {
      id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

variables {
  project = {
    name = "ado-project-validation"
  }
}

run "invalid_visibility" {
  command = plan

  variables {
    project = {
      name       = "ado-project-invalid"
      visibility = "internal"
    }
  }

  expect_failures = [
    var.project,
  ]
}

run "invalid_version_control" {
  command = plan

  variables {
    project = {
      name            = "ado-project-invalid"
      version_control = "Subversion"
    }
  }

  expect_failures = [
    var.project,
  ]
}

run "invalid_project_features_value" {
  command = plan

  variables {
    project_features = {
      boards = "maybe"
    }
  }

  expect_failures = [
    var.project_features,
  ]
}

run "invalid_dashboard_refresh" {
  command = plan

  variables {
    dashboards = [
      {
        name             = "Invalid Dashboard"
        refresh_interval = 10
      }
    ]
  }

  expect_failures = [
    var.dashboards,
  ]
}
