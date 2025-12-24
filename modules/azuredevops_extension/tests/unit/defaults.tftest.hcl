# Test default settings for Azure DevOps Extension

mock_provider "azuredevops" {}

run "defaults_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_extension.extension) == 0
    error_message = "No extensions should be created by default."
  }
}
