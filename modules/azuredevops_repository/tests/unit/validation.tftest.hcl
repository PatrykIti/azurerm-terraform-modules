# Placeholder validation test for Azure DevOps Repository

variables {
  name                = "example-azuredevops_repository"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "validation_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update validation tests for Azure DevOps Repository."
  }
}
