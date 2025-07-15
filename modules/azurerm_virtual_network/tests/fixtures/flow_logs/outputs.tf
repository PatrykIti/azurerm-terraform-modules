output "virtual_network_id" {
  description = "The ID of the created Virtual Network"
  value       = module.virtual_network.id
}

output "virtual_network_name" {
  description = "The name of the created Virtual Network"
  value       = module.virtual_network.name
}

output "virtual_network_address_space" {
  description = "The address space of the created Virtual Network"
  value       = module.virtual_network.address_space
}

output "virtual_network_guid" {
  description = "The GUID of the created Virtual Network"
  value       = module.virtual_network.guid
}

output "virtual_network_flow_log" {
  description = "Information about network flow log configuration"
  value       = module.virtual_network.flow_log
}

output "virtual_network_diagnostic_setting" {
  description = "Information about diagnostic settings"
  value       = module.virtual_network.diagnostic_setting
}

output "flow_logs_configuration" {
  description = "Summary of flow logs configuration"
  value = {
    flow_logs_enabled  = module.virtual_network.flow_log != null
    flow_log_version   = module.virtual_network.flow_log != null ? module.virtual_network.flow_log.version : null
    retention_days     = module.virtual_network.flow_log != null ? module.virtual_network.flow_log.retention_policy.days : null
    traffic_analytics  = module.virtual_network.flow_log != null ? module.virtual_network.flow_log.traffic_analytics.enabled : null
    monitoring_enabled = module.virtual_network.diagnostic_setting != null
  }
}

output "network_security_group_id" {
  description = "The ID of the network security group"
  value       = azurerm_network_security_group.test.id
}

output "storage_account_id" {
  description = "The ID of the storage account for flow logs"
  value       = azurerm_storage_account.flow.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.flow.id
}



output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.test.name
}

output "location" {
  description = "The Azure region where resources were created"
  value       = azurerm_resource_group.test.location
}
