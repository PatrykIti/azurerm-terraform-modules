output "postgresql_flexible_server_id" {
  description = "The PostgreSQL Flexible Server ID."
  value       = module.postgresql_flexible_server.id
}

output "active_directory_administrator" {
  description = "Azure AD administrator details."
  value       = module.postgresql_flexible_server.active_directory_administrator
}
