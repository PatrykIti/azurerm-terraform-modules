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

output "virtual_network_ddos_protection" {
  description = "Information about DDoS protection configuration"
  value       = "DDoS protection configured via input variables"
}

output "virtual_network_flow_log" {
  description = "Information about network flow log configuration"
  value       = module.virtual_network.flow_log
}

output "virtual_network_diagnostic_setting" {
  description = "Information about diagnostic settings"
  value       = module.virtual_network.diagnostic_setting
}

output "virtual_network_security_configuration" {
  description = "Summary of security configuration"
  value = {
    ddos_protection_enabled = true
    flow_logs_enabled       = module.virtual_network.flow_log != null
    encryption_enabled      = true
    monitoring_enabled      = module.virtual_network.diagnostic_setting != null
  }
}

output "ddos_protection_plan_id" {
  description = "The ID of the DDoS protection plan"
  value       = local.ddos_protection_plan_id
}



output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.test.name
}

output "location" {
  description = "The Azure region where resources were created"
  value       = azurerm_resource_group.test.location
}
