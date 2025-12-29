output "agent_pool_id" {
  description = "Agent pool ID."
  value       = module.azuredevops_agent_pools.agent_pool_id
}

output "agent_queue_ids" {
  description = "Map of agent queue IDs keyed by queue key/name."
  value       = module.azuredevops_agent_pools.agent_queue_ids
}

output "elastic_pool_id" {
  description = "Elastic pool ID when configured."
  value       = module.azuredevops_agent_pools.elastic_pool_id
}
