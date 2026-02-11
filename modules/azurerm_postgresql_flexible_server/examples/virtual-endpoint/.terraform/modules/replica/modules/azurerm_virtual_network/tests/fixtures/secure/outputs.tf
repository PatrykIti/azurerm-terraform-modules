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
  value       = "DDoS protection disabled due to Azure subscription limitation"
}


output "virtual_network_diagnostic_setting_id" {
  description = "ID of the diagnostic setting"
  value       = azurerm_monitor_diagnostic_setting.test.id
}

output "virtual_network_security_configuration" {
  description = "Summary of security configuration"
  value = {
    ddos_protection_enabled = false # Disabled due to Azure subscription limitation
    encryption_enabled      = true
    monitoring_enabled      = true
  }
}



output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.test.name
}

output "location" {
  description = "The Azure region where resources were created"
  value       = azurerm_resource_group.test.location
}
