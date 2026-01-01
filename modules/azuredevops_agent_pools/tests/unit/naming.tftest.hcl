# Test agent pool naming and elastic pool creation

mock_provider "azuredevops" {}

variables {
  name = "default-pool"

  elastic_pool = {
    name                   = "elastic-pool"
    service_endpoint_id    = "00000000-0000-0000-0000-000000000001"
    service_endpoint_scope = "00000000-0000-0000-0000-000000000000"
    azure_resource_id      = "resource-0001"
    desired_idle           = 1
    max_capacity           = 2
  }
}

run "pool_elastic_pool_plan" {
  command = plan

  assert {
    condition     = azuredevops_agent_pool.agent_pool.name == "default-pool"
    error_message = "Agent pool name should match the input."
  }

  assert {
    condition     = length(azuredevops_elastic_pool.elastic_pool) == 1
    error_message = "elastic_pool should create one elastic pool."
  }

  assert {
    condition     = azuredevops_elastic_pool.elastic_pool[0].name == "elastic-pool"
    error_message = "Elastic pool name should match the input."
  }
}
