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

output "virtual_network_peerings" {
  description = "Information about Virtual Network peerings"
  value       = module.virtual_network.peerings
}

output "virtual_network_dns_links" {
  description = "Information about Private DNS Zone links"
  value       = module.virtual_network.private_dns_zone_links
}

output "virtual_network_diagnostic_setting" {
  description = "Information about diagnostic settings"
  value       = module.virtual_network.diagnostic_setting
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
