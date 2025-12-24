# Placeholder naming test for Azure DevOps Repository

variables {
  name                = "example-azuredevops_repository"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "naming_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update naming tests for Azure DevOps Repository."
  }
}
