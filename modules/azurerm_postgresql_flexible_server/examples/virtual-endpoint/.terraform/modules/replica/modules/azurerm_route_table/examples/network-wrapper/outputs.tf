output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.example.name
}

output "subnet_ids" {
  description = "Map of subnet IDs"
  value = {
    app     = azurerm_subnet.app.id
    data    = azurerm_subnet.data.id
    gateway = azurerm_subnet.gateway.id
  }
}

output "route_table_id" {
  description = "The ID of the route table"
  value       = module.route_table.id
}

output "route_table_name" {
  description = "The name of the route table"
  value       = module.route_table.name
}

output "nsg_id" {
  description = "The ID of the network security group"
  value       = azurerm_network_security_group.example.id
}

output "subnet_route_associations" {
  description = "Map of subnet route table associations"
  value = {
    app  = azurerm_subnet_route_table_association.app.id
    data = azurerm_subnet_route_table_association.data.id
  }
}

output "subnet_nsg_associations" {
  description = "Map of subnet NSG associations"
  value = {
    app  = azurerm_subnet_network_security_group_association.app.id
    data = azurerm_subnet_network_security_group_association.data.id
  }
}