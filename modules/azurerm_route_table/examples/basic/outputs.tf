# Module Outputs
output "route_table_id" {
  description = "The ID of the Route Table"
  value       = module.route_table.id
}

output "route_table_name" {
  description = "The name of the Route Table"
  value       = module.route_table.name
}

output "bgp_route_propagation_enabled" {
  description = "Whether BGP route propagation is enabled"
  value       = module.route_table.bgp_route_propagation_enabled
}

output "routes" {
  description = "The routes configured in the Route Table"
  value       = module.route_table.routes
}

output "associated_subnet_ids" {
  description = "The subnet IDs associated with the Route Table"
  value       = module.route_table.associated_subnet_ids
}

# Supporting Resource Outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.example.name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = azurerm_subnet.example.id
}