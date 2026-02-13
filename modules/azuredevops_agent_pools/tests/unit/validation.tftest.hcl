# Test variable validation for Azure DevOps Agent Pools

mock_provider "azuredevops" {}

variables {
  name = "Default Pool"
}

run "invalid_pool_type" {
  command = plan

  variables {
    pool_type = "invalid"
  }

  expect_failures = [
    var.pool_type,
  ]
}
