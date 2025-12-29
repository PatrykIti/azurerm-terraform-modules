output "agent_pool_id" {
  description = "ID of the agent pool created by the module."
  value       = azuredevops_agent_pool.agent_pool.id
}

output "agent_queue_ids" {
  description = "Map of agent queue IDs keyed by queue key/name."
  value       = { for key, queue in azuredevops_agent_queue.agent_queue : key => queue.id }
}

output "elastic_pool_id" {
  description = "ID of the elastic pool when configured."
  value       = try(azuredevops_elastic_pool.elastic_pool[0].id, null)
}
