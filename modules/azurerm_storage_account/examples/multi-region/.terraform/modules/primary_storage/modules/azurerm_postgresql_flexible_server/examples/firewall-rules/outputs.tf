output "postgresql_flexible_server_id" {
  description = "The PostgreSQL Flexible Server ID."
  value       = module.postgresql_flexible_server.id
}

output "firewall_rules" {
  description = "Firewall rules created for the server."
  value       = module.postgresql_flexible_server.firewall_rules
}
