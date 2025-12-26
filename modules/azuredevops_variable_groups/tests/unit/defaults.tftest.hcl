# Test default settings for Azure DevOps Variable Groups

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "default-group"

  variables = [
    {
      name  = "key"
      value = "value"
    }
  ]
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = azuredevops_variable_group.variable_group.allow_access == false
    error_message = "allow_access should default to false."
  }

  assert {
    condition     = length(azuredevops_variable_group_permissions.variable_group_permissions) == 0
    error_message = "No variable group permissions should be created by default."
  }

  assert {
    condition     = length(azuredevops_library_permissions.library_permissions) == 0
    error_message = "No library permissions should be created by default."
  }
}
