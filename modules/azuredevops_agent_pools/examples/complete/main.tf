provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  elastic_pools = var.enable_elastic_pool ? [
    {
      name                = "${var.elastic_pool_name_prefix}-${random_string.suffix.result}"
      service_endpoint_id = var.service_endpoint_id
      azure_resource_id   = var.azure_resource_id
      desired_idle        = var.desired_idle
      max_capacity        = var.max_capacity
    }
  ] : []
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

  elastic_pools = local.elastic_pools
}
