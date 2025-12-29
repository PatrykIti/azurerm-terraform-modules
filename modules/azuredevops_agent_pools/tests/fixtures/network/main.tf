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
  source = "../../../"

  name = "${var.pool_name_prefix}-module-${random_string.suffix.result}"

  agent_queues = [
    {
      key           = "external"
      project_id    = var.project_id
      agent_pool_id = azuredevops_agent_pool.external.id
    }
  ]
}
