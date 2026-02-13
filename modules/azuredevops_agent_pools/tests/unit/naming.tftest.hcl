# Test agent pool naming

mock_provider "azuredevops" {}

variables {
  name = "default-pool"
}

run "pool_plan" {
  command = plan

  assert {
    condition     = azuredevops_agent_pool.agent_pool.name == "default-pool"
    error_message = "Agent pool name should match the input."
  }
}
