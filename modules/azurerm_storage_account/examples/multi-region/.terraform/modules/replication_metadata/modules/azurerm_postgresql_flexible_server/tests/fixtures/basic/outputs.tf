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

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = module.postgresql_flexible_server.public_network_access_enabled
}

output "database_name" {
  description = "Database name created for connectivity validation."
  value       = azurerm_postgresql_flexible_server_database.test.name
}
