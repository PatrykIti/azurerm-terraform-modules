# Test outputs for Azure DevOps Agent Pools

mock_provider "azuredevops" {
  mock_resource "azuredevops_agent_pool" {
    defaults = {
      id = "00000000-0000-0000-0000-000000000000"
    }
  }

  mock_resource "azuredevops_agent_queue" {
    defaults = {
      id = "queue-0001"
    }
  }

  mock_resource "azuredevops_elastic_pool" {
    defaults = {
      id = "elastic-0001"
    }
  }
}

variables {
  agent_pools = {
    default = {
      name = "Default Pool"
    }
    build = {
      name = "Build Pool"
    }
  }

  agent_queues = [
    {
      project_id     = "00000000-0000-0000-0000-000000000000"
      name           = "Default Queue"
      agent_pool_key = "default"
    },
    {
      project_id     = "00000000-0000-0000-0000-000000000000"
      name           = "Build Queue"
      agent_pool_key = "build"
    }
  ]

  elastic_pools = [
    {
      name                = "Elastic Pool"
      service_endpoint_id = "service-endpoint-0001"
      azure_resource_id   = "resource-0001"
      desired_idle        = 1
      max_capacity        = 2
    }
  ]
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = length(keys(output.agent_pool_ids)) == 2
    error_message = "agent_pool_ids should include all configured pools."
  }

  assert {
    condition     = length(keys(output.agent_queue_ids)) == 2
    error_message = "agent_queue_ids should include all configured queues."
  }

  assert {
    condition     = length(keys(output.elastic_pool_ids)) == 1
    error_message = "elastic_pool_ids should include configured elastic pools."
  }
}
