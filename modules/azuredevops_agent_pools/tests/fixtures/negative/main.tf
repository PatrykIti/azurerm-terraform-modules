# Negative test cases - should fail validation
provider "azuredevops" {}

module "azuredevops_agent_pools" {
  source = "../../../"

  agent_queues = [
    {
      project_id     = "00000000-0000-0000-0000-000000000000"
      name           = "ado-agent-queue-negative"
      agent_pool_id  = "00000000-0000-0000-0000-000000000000"
      agent_pool_key = "invalid"
    }
  ]
}
