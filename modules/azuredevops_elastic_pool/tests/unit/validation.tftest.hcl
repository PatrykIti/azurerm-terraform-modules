# Test variable validation for Azure DevOps Elastic Pool

mock_provider "azuredevops" {}

variables {
  name                   = "Elastic Pool"
  service_endpoint_id    = "00000000-0000-0000-0000-000000000001"
  service_endpoint_scope = "00000000-0000-0000-0000-000000000000"
  azure_resource_id      = "resource-0001"
}

run "invalid_max_capacity" {
  command = plan

  variables {
    max_capacity = 0
  }

  expect_failures = [
    var.max_capacity,
  ]
}

run "invalid_desired_idle" {
  command = plan

  variables {
    desired_idle = 3
    max_capacity = 2
  }

  expect_failures = [
    var.max_capacity,
  ]
}
