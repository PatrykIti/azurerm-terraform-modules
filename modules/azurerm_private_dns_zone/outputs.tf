output "id" {
  description = "The ID of the Private DNS Zone."
  value       = try(azurerm_private_dns_zone.main.id, null)
}

output "name" {
  description = "The name of the Private DNS Zone."
  value       = try(azurerm_private_dns_zone.main.name, null)
}

output "resource_group_name" {
  description = "The name of the resource group containing the Private DNS Zone."
  value       = try(azurerm_private_dns_zone.main.resource_group_name, null)
}

output "number_of_record_sets" {
  description = "The number of record sets in the Private DNS Zone."
  value       = try(azurerm_private_dns_zone.main.number_of_record_sets, null)
}

output "max_number_of_virtual_network_links" {
  description = "The maximum number of virtual network links allowed for the Private DNS Zone."
  value       = try(azurerm_private_dns_zone.main.max_number_of_virtual_network_links, null)
}

output "max_number_of_virtual_network_links_with_registration" {
  description = "The maximum number of virtual network links with registration enabled."
  value       = try(azurerm_private_dns_zone.main.max_number_of_virtual_network_links_with_registration, null)
}

output "soa_record" {
  description = "The SOA record configuration for the Private DNS Zone."
  value       = try(azurerm_private_dns_zone.main.soa_record[0], null)
}

output "tags" {
  description = "The tags assigned to the Private DNS Zone."
  value       = try(azurerm_private_dns_zone.main.tags, null)
}
