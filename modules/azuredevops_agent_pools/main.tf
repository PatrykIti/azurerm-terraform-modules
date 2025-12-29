# Azure DevOps Agent Pools

locals {
  agent_queues_by_key = {
    for agent_queue in var.agent_queues :
    coalesce(
      agent_queue.key,
      agent_queue.name,
      agent_queue.agent_pool_id == null ? null : tostring(agent_queue.agent_pool_id),
      agent_queue.project_id
    ) => agent_queue
  }
}

resource "azuredevops_agent_pool" "agent_pool" {
  name           = var.name
  auto_provision = var.auto_provision
  auto_update    = var.auto_update
  pool_type      = var.pool_type
}

resource "azuredevops_agent_queue" "agent_queue" {
  for_each = local.agent_queues_by_key

  project_id    = each.value.project_id
  name          = each.value.name
  agent_pool_id = each.value.name != null ? null : coalesce(each.value.agent_pool_id, tonumber(azuredevops_agent_pool.agent_pool.id))
}

resource "azuredevops_elastic_pool" "elastic_pool" {
  count = var.elastic_pool == null ? 0 : 1

  name                   = try(var.elastic_pool.name, null)
  service_endpoint_id    = try(var.elastic_pool.service_endpoint_id, null)
  service_endpoint_scope = try(var.elastic_pool.service_endpoint_scope, null)
  azure_resource_id      = try(var.elastic_pool.azure_resource_id, null)
  desired_idle           = try(var.elastic_pool.desired_idle, null)
  max_capacity           = try(var.elastic_pool.max_capacity, null)
  recycle_after_each_use = try(var.elastic_pool.recycle_after_each_use, null)
  time_to_live_minutes   = try(var.elastic_pool.time_to_live_minutes, null)
  agent_interactive_ui   = try(var.elastic_pool.agent_interactive_ui, null)
  auto_provision         = try(var.elastic_pool.auto_provision, null)
  auto_update            = try(var.elastic_pool.auto_update, null)
  project_id             = try(var.elastic_pool.project_id, null)
}
