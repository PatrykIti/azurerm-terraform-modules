output "id" {
  description = "The ID of the Private DNS Zone Virtual Network Link."
  value       = try(azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link.id, null)
}

output "name" {
  description = "The name of the Private DNS Zone Virtual Network Link."
  value       = try(azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link.name, null)
}

output "resource_group_name" {
  description = "The name of the resource group containing the Private DNS Zone."
  value       = try(azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link.resource_group_name, null)
}

output "private_dns_zone_name" {
  description = "The name of the Private DNS Zone associated with the link."
  value       = try(azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link.private_dns_zone_name, null)
}

output "virtual_network_id" {
  description = "The ID of the linked Virtual Network."
  value       = try(azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link.virtual_network_id, null)
}

output "registration_enabled" {
  description = "Whether auto-registration of VM records in the linked network is enabled."
  value       = try(azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link.registration_enabled, null)
}

output "resolution_policy" {
  description = "The DNS resolution policy applied to the Virtual Network Link."
  value       = try(azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link.resolution_policy, null)
}

output "tags" {
  description = "The tags assigned to the Virtual Network Link."
  value       = try(azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link.tags, null)
}
