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

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "location" {
  description = "The Azure region where resources were created"
  value       = azurerm_resource_group.example.location
}
