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

run "invalid_elastic_pool_capacity" {
  command = plan

  variables {
    elastic_pool = {
      name                   = "Elastic Pool"
      service_endpoint_id    = "00000000-0000-0000-0000-000000000001"
      service_endpoint_scope = "00000000-0000-0000-0000-000000000000"
      azure_resource_id      = "resource-0001"
      desired_idle           = 1
      max_capacity           = 0
    }
  }

  expect_failures = [
    var.elastic_pool,
  ]
}

run "invalid_elastic_pool_desired_idle" {
  command = plan

  variables {
    elastic_pool = {
      name                   = "Elastic Pool"
      service_endpoint_id    = "00000000-0000-0000-0000-000000000001"
      service_endpoint_scope = "00000000-0000-0000-0000-000000000000"
      azure_resource_id      = "resource-0001"
      desired_idle           = 3
      max_capacity           = 2
    }
  }

  expect_failures = [
    var.elastic_pool,
  ]
}
