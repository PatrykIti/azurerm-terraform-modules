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
      name           = "${var.pool_name_prefix}-default-${random_string.suffix.result}"
      auto_provision = true
      auto_update    = true
    }
    build = {
      name           = "${var.pool_name_prefix}-build-${random_string.suffix.result}"
      auto_provision = true
      auto_update    = false
    }
  }

  agent_queues = [
    {
      project_id     = var.project_id
      name           = "${var.queue_name_prefix}-default-${random_string.suffix.result}"
      agent_pool_key = "default"
    },
    {
      project_id     = var.project_id
      name           = "${var.queue_name_prefix}-build-${random_string.suffix.result}"
      agent_pool_key = "build"
    }
  ]
}
