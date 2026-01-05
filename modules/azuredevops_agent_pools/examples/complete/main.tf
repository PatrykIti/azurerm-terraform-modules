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

locals {
  elastic_pool = var.enable_elastic_pool ? {
    name                   = var.elastic_pool_name
    service_endpoint_id    = var.service_endpoint_id
    service_endpoint_scope = var.service_endpoint_scope
    azure_resource_id      = var.azure_resource_id
    desired_idle           = var.desired_idle
    max_capacity           = var.max_capacity
  } : null
}

module "azuredevops_agent_pools" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_agent_pools?ref=ADOAP1.0.0"

  name           = var.pool_name
  auto_provision = false
  auto_update    = true

  elastic_pool = local.elastic_pool
}
