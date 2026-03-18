output "agent_pool_id" {
  description = "ID of the agent pool created by the module."
  value       = azuredevops_agent_pool.agent_pool.id
}
