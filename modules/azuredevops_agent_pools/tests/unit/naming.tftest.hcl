# Test agent pool naming and queue mapping

mock_provider "azuredevops" {}

variables {
  name = "default-pool"

  agent_queues = [
    {
      key        = "default"
      project_id = "00000000-0000-0000-0000-000000000000"
    }
  ]
}

run "pool_queue_plan" {
  command = plan

  assert {
    condition     = azuredevops_agent_pool.agent_pool.name == "default-pool"
    error_message = "Agent pool name should match the input."
  }

  assert {
    condition     = length(azuredevops_agent_queue.agent_queue) == 1
    error_message = "agent_queues should create one queue."
  }
}
