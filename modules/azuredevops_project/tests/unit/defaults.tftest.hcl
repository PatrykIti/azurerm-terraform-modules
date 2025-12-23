# Placeholder defaults test for Azure DevOps Project

variables {
  name                = "example-azuredevops_project"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update defaults tests for Azure DevOps Project."
  }
}
