output "agent_pool_ids" {
  description = "Map of agent pool IDs keyed by pool key."
  value       = module.azuredevops_agent_pools.agent_pool_ids
}

output "agent_queue_ids" {
  description = "Map of agent queue IDs keyed by index."
  value       = module.azuredevops_agent_pools.agent_queue_ids
}

output "elastic_pool_ids" {
  description = "Map of elastic pool IDs keyed by index."
  value       = module.azuredevops_agent_pools.elastic_pool_ids
}
