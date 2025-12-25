output "name" {
  description = "The name of the Network Security Group."
  value       = module.network_security_group.name
}

output "resource_group_name" {
  description = "The resource group name."
  value       = azurerm_resource_group.test.name
}

output "diagnostic_settings_ids" {
  description = "Diagnostic settings IDs."
  value       = module.network_security_group.diagnostic_settings_ids
}

output "flow_log" {
  description = "Flow log configuration."
  value       = module.network_security_group.flow_log
}

output "flow_log_id" {
  description = "Flow log ID."
  value       = module.network_security_group.flow_log.id
}
