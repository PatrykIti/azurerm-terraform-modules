# Test default settings for Azure DevOps Agent Pools

mock_provider "azuredevops" {}

variables {
  name = "Default Pool"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = azuredevops_agent_pool.agent_pool.name == "Default Pool"
    error_message = "Agent pool name should match the input."
  }

  assert {
    condition     = azuredevops_agent_pool.agent_pool.auto_provision == false
    error_message = "auto_provision should default to false."
  }

  assert {
    condition     = azuredevops_agent_pool.agent_pool.auto_update == true
    error_message = "auto_update should default to true."
  }

  assert {
    condition     = azuredevops_agent_pool.agent_pool.pool_type == "automation"
    error_message = "pool_type should default to automation."
  }

  assert {
    condition     = length(azuredevops_agent_queue.agent_queue) == 0
    error_message = "No agent queues should be created by default."
  }

  assert {
    condition     = length(azuredevops_elastic_pool.elastic_pool) == 0
    error_message = "No elastic pools should be created by default."
  }
}
