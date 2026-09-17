output "postgresql_flexible_server_id" {
  description = "The PostgreSQL Flexible Server ID."
  value       = module.postgresql_flexible_server.id
}

output "backups" {
  description = "Manual backups created for the server."
  value       = module.postgresql_flexible_server.backups
}
