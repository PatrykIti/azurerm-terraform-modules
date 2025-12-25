# Test permission key behavior for the Azure DevOps Project Permissions module

mock_provider "azuredevops" {
  mock_resource "azuredevops_project_permissions" {
    defaults = {
      id = "perm-0001"
    }
  }

  mock_data "azuredevops_group" {
    defaults = {
      id = "vssgp.readers"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  permissions = [
    {
      key        = "readers"
      group_name = "Readers"
      scope      = "project"
      permissions = {
        GENERIC_READ = "Allow"
      }
      replace = false
    }
  ]
}

run "permission_key_set" {
  command = plan

  assert {
    condition     = length(azuredevops_project_permissions.permission) == 1
    error_message = "permissions should create one permission assignment."
  }
}
