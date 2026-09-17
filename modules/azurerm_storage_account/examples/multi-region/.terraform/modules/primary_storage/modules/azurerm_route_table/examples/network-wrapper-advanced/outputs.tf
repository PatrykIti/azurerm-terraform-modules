output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}

output "subnet_ids" {
  description = "Map of subnet IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "route_table_id" {
  description = "The ID of the route table"
  value       = module.route_table.id
}

output "subnet_route_associations" {
  description = "Map of subnet route table associations"
  value       = { for k, v in azurerm_subnet_route_table_association.associations : k => v.id }
}

output "subnet_nsg_associations" {
  description = "Map of subnet NSG associations"
  value       = { for k, v in azurerm_subnet_network_security_group_association.associations : k => v.id }
}