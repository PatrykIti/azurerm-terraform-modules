# Azure DevOps Agent Pools

resource "azuredevops_agent_pool" "agent_pool" {
  name           = var.name
  auto_provision = var.auto_provision
  auto_update    = var.auto_update
  pool_type      = var.pool_type
}

resource "azuredevops_elastic_pool" "elastic_pool" {
  count = var.elastic_pool == null ? 0 : 1

  name                   = var.elastic_pool.name
  service_endpoint_id    = var.elastic_pool.service_endpoint_id
  service_endpoint_scope = var.elastic_pool.service_endpoint_scope
  azure_resource_id      = var.elastic_pool.azure_resource_id
  desired_idle           = var.elastic_pool.desired_idle
  max_capacity           = var.elastic_pool.max_capacity
  recycle_after_each_use = var.elastic_pool.recycle_after_each_use
  time_to_live_minutes   = var.elastic_pool.time_to_live_minutes
  agent_interactive_ui   = var.elastic_pool.agent_interactive_ui
  auto_provision         = var.elastic_pool.auto_provision
  auto_update            = var.elastic_pool.auto_update
  project_id             = var.elastic_pool.project_id
}
