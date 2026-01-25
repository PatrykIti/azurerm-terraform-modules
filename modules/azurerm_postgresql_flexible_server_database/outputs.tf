output "id" {
  description = "The ID of the PostgreSQL Flexible Server Database."
  value       = try(azurerm_postgresql_flexible_server_database.database.id, null)
}

output "name" {
  description = "The name of the PostgreSQL Flexible Server Database."
  value       = try(azurerm_postgresql_flexible_server_database.database.name, null)
}

output "server_id" {
  description = "The server ID hosting the PostgreSQL Flexible Server Database."
  value       = try(azurerm_postgresql_flexible_server_database.database.server_id, null)
}

output "charset" {
  description = "The charset of the PostgreSQL Flexible Server Database."
  value       = try(azurerm_postgresql_flexible_server_database.database.charset, null)
}

output "collation" {
  description = "The collation of the PostgreSQL Flexible Server Database."
  value       = try(azurerm_postgresql_flexible_server_database.database.collation, null)
}
