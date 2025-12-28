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
  name = "${var.pool_name_prefix}-external-${random_string.suffix.result}"
}

module "azuredevops_agent_pools" {
  source = "../../../"

  name           = "${var.pool_name_prefix}-default-${random_string.suffix.result}"
  auto_provision = false
  auto_update    = true

  agent_queues = [
    {
      key        = "default"
      project_id = var.project_id
    },
    {
      key           = "external"
      project_id    = var.project_id
      agent_pool_id = azuredevops_agent_pool.external.id
    }
  ]
}
