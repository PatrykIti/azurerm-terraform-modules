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

output "subnets" {
  description = "Information about created subnets"
  value       = module.virtual_network.subnets
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.virtual_network.subnet_ids
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes"
  value       = module.virtual_network.subnet_address_prefixes
}

output "network_security_group_web_id" {
  description = "The ID of the Web NSG"
  value       = azurerm_network_security_group.web.id
}

output "network_security_group_app_id" {
  description = "The ID of the App NSG"
  value       = azurerm_network_security_group.app.id
}

output "route_table_id" {
  description = "The ID of the route table"
  value       = azurerm_route_table.test.id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.test.name
}

output "location" {
  description = "The Azure region where resources were created"
  value       = azurerm_resource_group.test.location
}