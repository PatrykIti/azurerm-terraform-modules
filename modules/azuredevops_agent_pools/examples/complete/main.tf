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

locals {
  elastic_pool = var.enable_elastic_pool ? {
    name                   = "${var.elastic_pool_name_prefix}-${random_string.suffix.result}"
    service_endpoint_id    = var.service_endpoint_id
    service_endpoint_scope = var.service_endpoint_scope
    azure_resource_id      = var.azure_resource_id
    desired_idle           = var.desired_idle
    max_capacity           = var.max_capacity
  } : null
}

resource "azuredevops_agent_pool" "external" {
  name = "${var.pool_name_prefix}-external-${random_string.suffix.result}"
}

module "azuredevops_agent_pools" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_agent_pools?ref=ADOAP1.0.0"

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

  elastic_pool = local.elastic_pool
}
