output "postgresql_flexible_server_database_id" {
  description = "The ID of the created PostgreSQL Flexible Server Database."
  value       = module.postgresql_flexible_server_database.id
}

output "postgresql_flexible_server_database_name" {
  description = "The name of the created PostgreSQL Flexible Server Database."
  value       = module.postgresql_flexible_server_database.name
}

output "postgresql_flexible_server_id" {
  description = "The ID of the PostgreSQL Flexible Server."
  value       = module.postgresql_flexible_server.id
}

output "resource_group_name" {
  description = "The name of the resource group containing the server."
  value       = azurerm_resource_group.example.name
}
