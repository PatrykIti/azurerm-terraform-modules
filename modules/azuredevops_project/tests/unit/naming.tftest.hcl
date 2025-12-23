# Placeholder naming test for Azure DevOps Project

variables {
  name                = "example-azuredevops_project"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "naming_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update naming tests for Azure DevOps Project."
  }
}
