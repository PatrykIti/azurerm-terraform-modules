# Test default settings for Azure DevOps Agent Pools

mock_provider "azuredevops" {}

run "defaults_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_agent_pool.pool) == 0
    error_message = "No agent pools should be created by default."
  }

  assert {
    condition     = length(azuredevops_agent_queue.queue) == 0
    error_message = "No agent queues should be created by default."
  }

  assert {
    condition     = length(azuredevops_elastic_pool.elastic_pool) == 0
    error_message = "No elastic pools should be created by default."
  }
}
