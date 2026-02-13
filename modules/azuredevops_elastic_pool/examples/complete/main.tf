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

module "azuredevops_elastic_pool" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_elastic_pool?ref=ADOEPv1.0.0"

  name                   = var.elastic_pool_name
  service_endpoint_id    = var.service_endpoint_id
  service_endpoint_scope = var.service_endpoint_scope
  azure_resource_id      = var.azure_resource_id
  desired_idle           = var.desired_idle
  max_capacity           = var.max_capacity
  recycle_after_each_use = var.recycle_after_each_use
  time_to_live_minutes   = var.time_to_live_minutes
  agent_interactive_ui   = var.agent_interactive_ui
  auto_provision         = var.auto_provision
  auto_update            = var.auto_update
  project_id             = var.project_id
}
