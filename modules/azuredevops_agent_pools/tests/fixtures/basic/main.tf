provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_agent_pools" {
  source = "../../"

  agent_pools = {
    default = {
      name = "${var.pool_name_prefix}-${random_string.suffix.result}"
    }
  }

  agent_queues = [
    {
      project_id     = var.project_id
      name           = "${var.queue_name_prefix}-${random_string.suffix.result}"
      agent_pool_key = "default"
    }
  ]
}
