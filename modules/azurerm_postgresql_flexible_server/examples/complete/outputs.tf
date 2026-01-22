output "postgresql_flexible_server_id" {
  description = "The ID of the created PostgreSQL Flexible Server"
  value       = module.postgresql_flexible_server.id
}

output "postgresql_flexible_server_name" {
  description = "The name of the created PostgreSQL Flexible Server"
  value       = module.postgresql_flexible_server.name
}
