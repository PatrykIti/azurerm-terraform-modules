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


output "virtual_network_diagnostic_setting_id" {
  description = "ID of the diagnostic setting"
  value       = azurerm_monitor_diagnostic_setting.test.id
}

output "flow_logs_configuration" {
  description = "Summary of flow logs configuration"
  value = {
    flow_logs_enabled  = true
    flow_log_version   = azurerm_network_watcher_flow_log.test.version
    flow_log_id        = azurerm_network_watcher_flow_log.test.id
    storage_account_id = azurerm_network_watcher_flow_log.test.storage_account_id
    monitoring_enabled = true
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
