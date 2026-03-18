# Test outputs for Azure DevOps Agent Pools

mock_provider "azuredevops" {
  mock_resource "azuredevops_agent_pool" {
    defaults = {
      id = "1"
    }
  }
}

variables {
  name = "Default Pool"
}

run "outputs_apply" {
  command = apply

  assert {
    condition     = output.agent_pool_id == "1"
    error_message = "agent_pool_id should match the mock ID."
  }
}
