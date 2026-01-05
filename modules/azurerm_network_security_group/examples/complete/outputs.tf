output "network_security_group_id" {
  description = "The ID of the created Network Security Group."
  value       = module.network_security_group.id
}

output "network_security_group_name" {
  description = "The name of the created Network Security Group."
  value       = module.network_security_group.name
}

output "security_rule_ids" {
  description = "Map of security rule names to their IDs."
  value       = module.network_security_group.security_rule_ids
}
output "application_security_group_ids" {
  description = "The IDs of the created Application Security Groups."
  value = {
    web_servers      = azurerm_application_security_group.web_servers.id
    database_servers = azurerm_application_security_group.database_servers.id
  }
}
