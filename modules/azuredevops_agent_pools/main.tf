# Azure DevOps Agent Pools

locals {
  agent_pool_ids = { for key, pool in azuredevops_agent_pool.pool : key => pool.id }
}

resource "azuredevops_agent_pool" "pool" {
  for_each = var.agent_pools

  name           = coalesce(each.value.name, each.key)
  auto_provision = each.value.auto_provision
  auto_update    = each.value.auto_update
  pool_type      = each.value.pool_type
}

resource "azuredevops_agent_queue" "queue" {
  for_each = { for index, queue in var.agent_queues : index => queue }

  project_id    = each.value.project_id
  name          = each.value.name
  agent_pool_id = each.value.agent_pool_id != null ? each.value.agent_pool_id : local.agent_pool_ids[each.value.agent_pool_key]
}

resource "azuredevops_elastic_pool" "elastic_pool" {
  for_each = { for index, pool in var.elastic_pools : index => pool }

  name                = each.value.name
  service_endpoint_id = each.value.service_endpoint_id
  azure_resource_id   = each.value.azure_resource_id
  desired_idle        = each.value.desired_idle
  max_capacity        = each.value.max_capacity
}
