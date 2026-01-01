# Test outputs for Azure DevOps Agent Pools

mock_provider "azuredevops" {
  mock_resource "azuredevops_agent_pool" {
    defaults = {
      id = "1"
    }
  }

  mock_resource "azuredevops_elastic_pool" {
    defaults = {
      id = "elastic-0001"
    }
  }
}

variables {
  name = "Default Pool"

  elastic_pool = {
    name                   = "Elastic Pool"
    service_endpoint_id    = "00000000-0000-0000-0000-000000000001"
    service_endpoint_scope = "00000000-0000-0000-0000-000000000000"
    azure_resource_id      = "resource-0001"
    desired_idle           = 1
    max_capacity           = 2
  }
}

run "outputs_apply" {
  command = apply

  assert {
    condition     = output.agent_pool_id == "1"
    error_message = "agent_pool_id should match the mock ID."
  }

  assert {
    condition     = output.elastic_pool_id == "elastic-0001"
    error_message = "elastic_pool_id should match the mock ID."
  }
}
