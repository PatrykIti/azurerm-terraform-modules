# Placeholder outputs test for Azure DevOps Repository

variables {
  name                = "example-azuredevops_repository"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update outputs tests for Azure DevOps Repository."
  }
}
