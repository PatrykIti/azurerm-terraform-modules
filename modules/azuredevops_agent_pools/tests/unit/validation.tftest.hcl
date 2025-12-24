# Test variable validation for Azure DevOps Agent Pools

mock_provider "azuredevops" {}

variables {
  agent_pools = {
    default = {
      name = "Default Pool"
    }
  }
}

run "invalid_queue_selector" {
  command = plan

  variables {
    agent_queues = [
      {
        project_id     = "00000000-0000-0000-0000-000000000000"
        name           = "Invalid Queue"
        agent_pool_id  = "00000000-0000-0000-0000-000000000000"
        agent_pool_key = "default"
      }
    ]
  }

  expect_failures = [
    var.agent_queues,
  ]
}

run "empty_queue_name" {
  command = plan

  variables {
    agent_queues = [
      {
        project_id     = "00000000-0000-0000-0000-000000000000"
        name           = "  "
        agent_pool_key = "default"
      }
    ]
  }

  expect_failures = [
    var.agent_queues,
  ]
}

run "invalid_elastic_pool_capacity" {
  command = plan

  variables {
    elastic_pools = [
      {
        name                = "Elastic Pool"
        service_endpoint_id = "service-endpoint-0001"
        azure_resource_id   = "resource-0001"
        max_capacity        = 0
      }
    ]
  }

  expect_failures = [
    var.elastic_pools,
  ]
}

run "invalid_elastic_pool_desired_idle" {
  command = plan

  variables {
    elastic_pools = [
      {
        name                = "Elastic Pool"
        service_endpoint_id = "service-endpoint-0001"
        azure_resource_id   = "resource-0001"
        desired_idle        = 3
        max_capacity        = 2
      }
    ]
  }

  expect_failures = [
    var.elastic_pools,
  ]
}
