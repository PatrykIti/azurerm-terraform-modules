# Test variable validation for Azure DevOps Service Endpoints

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "invalid_permissions" {
  command = plan

  variables {
    serviceendpoint_permissions = [
      {
        principal   = ""
        permissions = {
          Use = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.serviceendpoint_permissions,
  ]
}
