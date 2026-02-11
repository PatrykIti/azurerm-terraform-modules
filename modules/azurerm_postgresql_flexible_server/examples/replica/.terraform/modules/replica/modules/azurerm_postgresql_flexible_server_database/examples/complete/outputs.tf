output "postgresql_flexible_server_database_id" {
  description = "The ID of the created PostgreSQL Flexible Server Database"
  value       = module.postgresql_flexible_server_database.id
}

output "postgresql_flexible_server_database_name" {
  description = "The name of the created PostgreSQL Flexible Server Database"
  value       = module.postgresql_flexible_server_database.name
}
