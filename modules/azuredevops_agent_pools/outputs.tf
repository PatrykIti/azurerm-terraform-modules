output "agent_pool_ids" {
  description = "Map of agent pool IDs keyed by pool key."
  value       = { for key, pool in azuredevops_agent_pool.pool : key => pool.id }
}

output "agent_queue_ids" {
  description = "Map of agent queue IDs keyed by index."
  value       = { for key, queue in azuredevops_agent_queue.queue : key => queue.id }
}

output "elastic_pool_ids" {
  description = "Map of elastic pool IDs keyed by index."
  value       = { for key, pool in azuredevops_elastic_pool.elastic_pool : key => pool.id }
}
