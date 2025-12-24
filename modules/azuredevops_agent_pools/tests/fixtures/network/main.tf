provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azuredevops_agent_pool" "external" {
  name = "${var.pool_name_prefix}-${random_string.suffix.result}"
}

module "azuredevops_agent_pools" {
  source = "../../"

  agent_queues = [
    {
      project_id    = var.project_id
      name          = "${var.queue_name_prefix}-${random_string.suffix.result}"
      agent_pool_id = azuredevops_agent_pool.external.id
    }
  ]
}
