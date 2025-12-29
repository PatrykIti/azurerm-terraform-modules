# Negative test cases - should fail validation
terraform {
  required_version = ">= 1.12.2"
  required_providers {

    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

module "azuredevops_agent_pools" {
  source = "../../../"

  name = "invalid-agent-pool"

  agent_queues = [
    {
      project_id    = "00000000-0000-0000-0000-000000000000"
      name          = "ado-agent-queue-negative"
      agent_pool_id = 1
    }
  ]
}
