# Test default settings for Azure DevOps Service Endpoints

mock_provider "azuredevops" {}

run "defaults_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_serviceendpoint_generic.generic) == 0
    error_message = "No service endpoints should be created by default."
  }

  assert {
    condition     = length(azuredevops_serviceendpoint_permissions.permissions) == 0
    error_message = "No service endpoint permissions should be created by default."
  }
}
