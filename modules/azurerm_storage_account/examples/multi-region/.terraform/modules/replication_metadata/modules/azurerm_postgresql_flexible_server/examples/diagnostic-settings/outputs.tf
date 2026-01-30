output "postgresql_flexible_server_id" {
  description = "The PostgreSQL Flexible Server ID."
  value       = module.postgresql_flexible_server.id
}

output "postgresql_flexible_server_name" {
  description = "The PostgreSQL Flexible Server name."
  value       = module.postgresql_flexible_server.name
}

output "log_analytics_workspace_id" {
  description = "The Log Analytics workspace ID."
  value       = azurerm_log_analytics_workspace.example.id
}
