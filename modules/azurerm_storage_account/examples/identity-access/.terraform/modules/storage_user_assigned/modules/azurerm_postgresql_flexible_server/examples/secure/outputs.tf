output "postgresql_flexible_server_id" {
  description = "The PostgreSQL Flexible Server ID."
  value       = module.postgresql_flexible_server.id
}

output "postgresql_flexible_server_name" {
  description = "The PostgreSQL Flexible Server name."
  value       = module.postgresql_flexible_server.name
}

output "postgresql_flexible_server_fqdn" {
  description = "The PostgreSQL Flexible Server FQDN."
  value       = module.postgresql_flexible_server.fqdn
}

output "resource_group_name" {
  description = "The resource group name."
  value       = azurerm_resource_group.example.name
}
