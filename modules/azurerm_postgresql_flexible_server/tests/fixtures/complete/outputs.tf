output "postgresql_flexible_server_id" {
  description = "The ID of the created PostgreSQL Flexible Server"
  value       = module.postgresql_flexible_server.id
}

output "postgresql_flexible_server_name" {
  description = "The name of the created PostgreSQL Flexible Server"
  value       = module.postgresql_flexible_server.name
}

output "resource_group_name" {
  description = "The resource group name."
  value       = azurerm_resource_group.example.name
}

output "log_analytics_workspace_id" {
  description = "The Log Analytics workspace ID."
  value       = azurerm_log_analytics_workspace.example.id
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = module.postgresql_flexible_server.public_network_access_enabled
}
