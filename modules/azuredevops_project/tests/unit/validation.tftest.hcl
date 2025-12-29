# Test variable validation for the Azure DevOps Project module

mock_provider "azuredevops" {
  mock_resource "azuredevops_project" {
    defaults = {
      id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

variables {
  name = "ado-project-validation"
}

run "invalid_visibility" {
  command = plan

  variables {
    name       = "ado-project-invalid"
    visibility = "internal"
  }

  expect_failures = [
    var.visibility,
  ]
}

run "invalid_version_control" {
  command = plan

  variables {
    name            = "ado-project-invalid"
    version_control = "Subversion"
  }

  expect_failures = [
    var.version_control,
  ]
}

run "invalid_features_value" {
  command = plan

  variables {
    features = {
      boards = "maybe"
    }
  }

  expect_failures = [
    var.features,
  ]
}

run "invalid_features_key" {
  command = plan

  variables {
    features = {
      widgets = "enabled"
    }
  }

  expect_failures = [
    var.features,
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
