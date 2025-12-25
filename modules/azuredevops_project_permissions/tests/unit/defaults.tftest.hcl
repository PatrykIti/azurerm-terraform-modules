# Test default settings for the Azure DevOps Project Permissions module

mock_provider "azuredevops" {
  mock_resource "azuredevops_project_permissions" {}

  mock_data "azuredevops_group" {
    defaults = {
      id = "vssgp.default"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "verify_defaults" {
  command = plan

  assert {
    condition     = length(azuredevops_project_permissions.permission) == 0
    error_message = "No permissions should be created by default."
  }
}
