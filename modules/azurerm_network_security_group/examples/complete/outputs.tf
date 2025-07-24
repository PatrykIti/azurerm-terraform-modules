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

output "flow_log_id" {
  description = "The ID of the NSG Flow Log resource."
  value       = module.network_security_group.flow_log_id
}

output "flow_log_enabled" {
  description = "Whether Flow Logs are enabled."
  value       = module.network_security_group.flow_log_enabled
}

output "traffic_analytics_enabled" {
  description = "Whether Traffic Analytics is enabled."
  value       = module.network_security_group.traffic_analytics_enabled
}

output "diagnostic_settings_ids" {
  description = "Map of diagnostic setting names to their IDs."
  value       = module.network_security_group.diagnostic_settings_ids
}

output "diagnostic_settings_count" {
  description = "Number of diagnostic settings configured."
  value       = module.network_security_group.diagnostic_settings_count
}

output "application_security_group_ids" {
  description = "The IDs of the created Application Security Groups."
  value = {
    web_servers      = azurerm_application_security_group.web_servers.id
    database_servers = azurerm_application_security_group.database_servers.id
  }
}