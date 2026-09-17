output "agent_pool_id" {
  description = "ID of the agent pool created by the module."
  value       = azuredevops_agent_pool.agent_pool.id
}

output "elastic_pool_id" {
  description = "ID of the elastic pool when configured."
  value       = var.elastic_pool == null ? null : azuredevops_elastic_pool.elastic_pool[0].id
}
