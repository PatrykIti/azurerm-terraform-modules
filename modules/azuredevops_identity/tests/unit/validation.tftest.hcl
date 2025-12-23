# Placeholder validation test for Azure DevOps Identity

variables {
  name                = "example-azuredevops_identity"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "validation_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update validation tests for Azure DevOps Identity."
  }
}
