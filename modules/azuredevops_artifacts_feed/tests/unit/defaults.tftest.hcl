# Test default settings for Azure DevOps Variable Groups

mock_provider "azuredevops" {}

run "defaults_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_variable_group.variable_group) == 0
    error_message = "No variable groups should be created by default."
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
