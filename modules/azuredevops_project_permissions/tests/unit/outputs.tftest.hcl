# Test outputs for the Azure DevOps Project Permissions module

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

run "outputs_plan" {
  command = apply

  assert {
    condition     = output.permission_ids["readers"] != null
    error_message = "permission_ids should include configured permissions."
  }

  assert {
    condition     = output.permission_principals["readers"] == "vssgp.readers"
    error_message = "permission_principals should resolve group principals."
  }
}
