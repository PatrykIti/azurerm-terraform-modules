# Placeholder defaults test for Azure DevOps Identity

variables {
  name                = "example-azuredevops_identity"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update defaults tests for Azure DevOps Identity."
  }
}
