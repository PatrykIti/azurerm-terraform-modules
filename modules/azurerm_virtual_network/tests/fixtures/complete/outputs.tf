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

output "virtual_network_peering_id" {
  description = "ID of the Virtual Network peering"
  value       = azurerm_virtual_network_peering.test.id
}

output "virtual_network_dns_link_id" {
  description = "ID of the Private DNS Zone link"
  value       = azurerm_private_dns_zone_virtual_network_link.test.id
}

output "virtual_network_diagnostic_setting_id" {
  description = "ID of the diagnostic setting"
  value       = azurerm_monitor_diagnostic_setting.test.id
}

output "virtual_network_configuration" {
  description = "Summary of Virtual Network configuration"
  value       = module.virtual_network.network_configuration
}

output "peer_virtual_network_id" {
  description = "The ID of the peer Virtual Network"
  value       = azurerm_virtual_network.peer.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.test.id
}

output "storage_account_id" {
  description = "The ID of the storage account for diagnostics"
  value       = azurerm_storage_account.test.id
}

output "private_dns_zone_id" {
  description = "The ID of the private DNS zone"
  value       = azurerm_private_dns_zone.test.id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.test.name
}

output "location" {
  description = "The Azure region where resources were created"
  value       = azurerm_resource_group.test.location
}

output "network_security_group_ids" {
  description = "IDs of the network security groups (empty - NSGs are managed by separate module)"
  value       = {}
}

output "ddos_protection_enabled" {
  description = "Whether DDoS protection is enabled"
  value       = module.virtual_network.network_configuration.ddos_protection_enabled
}

output "subnet_ids" {
  description = "IDs of subnets (empty - subnets are managed separately)"
  value       = {}
}

output "dns_servers" {
  description = "DNS servers configured for the Virtual Network"
  value       = module.virtual_network.dns_servers
}
