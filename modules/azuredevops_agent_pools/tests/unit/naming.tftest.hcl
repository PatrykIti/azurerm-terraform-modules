# Test agent pool naming and queue mapping

mock_provider "azuredevops" {}

variables {
  agent_pools = {
    default = {}
  }

  agent_queues = [
    {
      project_id     = "00000000-0000-0000-0000-000000000000"
      name           = "ado-queue-default"
      agent_pool_key = "default"
    }
  ]
}

run "pool_queue_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_agent_pool.pool) == 1
    error_message = "agent_pools should create one pool."
  }

  assert {
    condition     = azuredevops_agent_pool.pool["default"].name == "default"
    error_message = "Pool name should default to the map key."
  }

  assert {
    condition     = length(azuredevops_agent_queue.queue) == 1
    error_message = "agent_queues should create one queue."
  }
}
