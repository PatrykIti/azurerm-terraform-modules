output "postgresql_flexible_server_id" {
  description = "The PostgreSQL Flexible Server ID."
  value       = module.postgresql_flexible_server.id
}

output "postgresql_flexible_server_name" {
  description = "The PostgreSQL Flexible Server name."
  value       = module.postgresql_flexible_server.name
}

output "configurations" {
  description = "Applied configuration map."
  value       = module.postgresql_flexible_server.configurations
}
