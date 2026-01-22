output "id" {
  description = "The ID of the PostgreSQL Flexible Server."
  value       = try(azurerm_postgresql_flexible_server.postgresql_flexible_server.id, null)
}

output "name" {
  description = "The name of the PostgreSQL Flexible Server."
  value       = try(azurerm_postgresql_flexible_server.postgresql_flexible_server.name, null)
}

output "location" {
  description = "The location of the PostgreSQL Flexible Server."
  value       = try(azurerm_postgresql_flexible_server.postgresql_flexible_server.location, null)
}

output "resource_group_name" {
  description = "The name of the resource group containing the PostgreSQL Flexible Server."
  value       = try(azurerm_postgresql_flexible_server.postgresql_flexible_server.resource_group_name, null)
}

output "fqdn" {
  description = "The FQDN of the PostgreSQL Flexible Server."
  value       = try(azurerm_postgresql_flexible_server.postgresql_flexible_server.fqdn, null)
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled for the PostgreSQL Flexible Server."
  value       = try(azurerm_postgresql_flexible_server.postgresql_flexible_server.public_network_access_enabled, null)
}

output "configurations" {
  description = "Map of PostgreSQL server configurations keyed by name."
  value       = azurerm_postgresql_flexible_server_configuration.configurations
}

output "firewall_rules" {
  description = "Map of PostgreSQL firewall rules keyed by name."
  value       = azurerm_postgresql_flexible_server_firewall_rule.firewall_rules
}

output "active_directory_administrator" {
  description = "Active Directory administrator configuration for the PostgreSQL Flexible Server."
  value       = try(azurerm_postgresql_flexible_server_active_directory_administrator.active_directory_administrator[0], null)
}

output "virtual_endpoints" {
  description = "Map of PostgreSQL Flexible Server virtual endpoints keyed by name."
  value       = azurerm_postgresql_flexible_server_virtual_endpoint.virtual_endpoints
}

output "backups" {
  description = "Map of PostgreSQL Flexible Server backups keyed by name."
  value       = azurerm_postgresql_flexible_server_backup.backups
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no categories were available after filtering."
  value       = local.diagnostic_settings_skipped
}

output "tags" {
  description = "The tags assigned to the PostgreSQL Flexible Server."
  value       = try(azurerm_postgresql_flexible_server.postgresql_flexible_server.tags, null)
}
